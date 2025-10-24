## Bench is a type of appliance that allows players to place or take items.
## It does not perform any specific actions like cooking or processing.
class_name Bench
extends UnPoweredAppliance

@export var invalid_food: Array[String] = [] ## Class names that can not be placed in this equipment

var item_slots: Array[Vector3] = []  ## Where to place items
var inflammable_component: Inflammable
var abstract_throwable_rotation = Vector3(0, 12.1, 0)

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/newmodels/furniture/BasicBench.glb")
	_setup_inflammable()
	appliance_name = "Bench"


## Setup the bench
func _ready():
	super._ready()
	invalid_food = ["Water"] # Example of invalid food
	capacity = 1
	_setup_item_slots()


## Setup inflammable component
func _setup_inflammable():
	inflammable_component = Inflammable.new()
	add_child(inflammable_component)


## Override upgradable setup in concrete appliances
func _setup_upgradable():
	super._setup_upgradable()


## Setup cookware slots, should be overridden by subclasses
## Default implementation expect one Cookware slot in the center
func _setup_item_slots():
	for i in range(capacity):
		var slot_position = Vector3(0.0, size.y * 0.65, 0.0)
		item_slots.append(slot_position)


## Apply position and direction to item at given slot
func _position_item(item: Node3D, slot_index: int):
	if item:
		item.restore_original_transform()
		if item is AbstractThrowable:
			item.rotate_abstract_throwable(abstract_throwable_rotation)
		elif item is Equipment:
			item.rotate_by(deg_to_rad(abstract_throwable_rotation.y))
	item.position = item_slots[slot_index]


## Place an item onto this appliance
## @param item: The Node to place on this appliance
func _put(item: Node) -> void:
	super._put(item)
	_position_item(item, contents.size() - 1)
	Debug.cook_log("Placed item on Bench: " + item.get_script().get_global_name())


## Remove and return item at specific index
## @param index: Index of item to remove
## @return: The Node that was removed, or null if invalid index
func take_at(index: int) -> Node:
	if index < 0 or index >= contents.size() or index >= contents_names.size():
		return null
	var item = contents.pop_at(index)
	remove_child(item)
	contents_names.remove_at(index)
	return item


## Take a food item from the bench
## @return: The Food item that was taken, or null if none found
func take_food() -> Food:
	for i in range(contents.size()):
		if contents[i] is Food:
			return take_at(i) as Food
	return null


## Check if this appliance can accept the given item
## @param item: The Node to test for acceptance
## @return: True if item can be placed, false otherwise
func _can_accept(item: Node) -> bool:
	var acceptable = super._can_accept(item)
	if not acceptable:
		return false
	return is_valid_food(item) or item is Equipment or item is Plate


## Check if food item is valid for the Bench
func is_valid_food(item: Node) -> bool:
	if not item is Food:
		return false
	return not item.get_script().get_global_name() in invalid_food


## Override unsupported methods to prevent misuse ------------------------------
func start_action() -> bool:
	assert(false, "Bench does not support starting actions")
	return false
#-------------------------------------------------------------------------------


## Handle fire event
func on_fire() -> void:
	current_status = Status.UNABLE
	for i in range(contents.size() - 1, -1, -1):
		var food = contents[i]
		if food is Food:
			contents.erase(food)
			remove_child(food)
			food.queue_free()


## For Player interaction --------------------------------------------------------------------------

## Perform action depend on what player is holding
## @param _item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(item: Node) -> void:
	# If player has nothing: move item from appliance to player (if exists), return true
	if not item:
		take_request()
		return
	# If player has food: try to put it in Cookware
	if item is Food:
		for content in contents:
			if content is Cookware:
				content.player_has(item)
				return
	# If player has plate: try to serve food from Cookware
	if item is Plate:
		var can_serve = _can_serve_to_plate(item)
		if can_serve != -1:
			serve_request(item, can_serve)
			return
	# If player has cookware:
	if item is Cookware:
		# try to transfer contents from bench to cookware
		if _can_transfer(item):
			transfer_request(item)
			return
		# If bench has plate: try to serve food to plate
		var plate = contents.back()
		if plate and plate is Plate and plate.is_ready():
			served_on_plate_request(plate, item)
			return
	# If item_in_hand exists: depend on if appliance can accept it
	put_request(item)


## Check if the plate can accept the current contents
## @param plate: The Node to check for acceptance
## @return: 1 for Food, 2 for Cookware with Food, -1 for cannot serve
func _can_serve_to_plate(plate: Plate) -> int:
	if contents.is_empty():
		Debug.info("Nothing to serve from: " +  name)
		return -1
	if not plate.is_ready(): # Method in Plate, checks if plate is ready
		Debug.info("Plate is not ready")
		return -1
	var item = contents[0]
	if item is Food:
		return 1
	elif item is Cookware:
		if item.is_empty():
			Debug.info("Nothing to serve from: " + item.name)
			return -1
		return 2
	else:
		Debug.info("Cannot serve from: " + name + ", not Food or Cookware")
		return -1


## Serve food from Cookware to Plate
## @param plate: The Plate to serve food to
func serve_request(plate: Plate, can_serve: int) -> void:
	if ENetManager.is_host():
		if can_serve == 1:
			plate.add_list_items([take()])
		elif can_serve == 2:
			plate.add_list_items(contents[0].take_all())
		_client_serve.rpc(ENetManager.get_my_id(), can_serve)
		return
	_serve_as_host.rpc_id(1, ENetManager.get_my_id())


## Host-side method to handle serve requests from clients
## @param player_id: The id of the player who is serving the food
@rpc("any_peer", "call_remote", "reliable")
func _serve_as_host(player_id: int, can_serve: int) -> void:
	if not ENetManager.is_host():
		return
	var plate = GlobalScript.get_local_player_by_id(player_id).item_in_hand
	if not plate or not (plate is Plate):
		Debug.info("Player is not holding a plate")
		return
	if _can_serve_to_plate(plate) != can_serve:
		return
	if can_serve == 1:
		plate.add_list_items([take()])
	elif can_serve == 2:
		plate.add_list_items(contents[0].take_all())
	_client_serve.rpc(ENetManager.get_my_id(), can_serve)


## Client-side method to serve food to plate, called by host
## @param player_id: The id of the player who is serving the food
@rpc("authority", "call_remote", "reliable")
func _client_serve(player_id: int, can_serve: int) -> void:
	var plate = GlobalScript.get_local_player_by_id(player_id).item_in_hand
	if not plate or not (plate is Plate):
		Debug.info("Player is not holding a plate")
		return
	if _can_serve_to_plate(plate) != can_serve:
		return
	if can_serve == 1:
		plate.add_list_items([take()])
	elif can_serve == 2:
		plate.add_list_items(contents[0].take_all())


## Check if bench can transfer contents to given cookware
## @param item: must be Cookware
## @return: True if transfer is possible, false otherwise
func _can_transfer(item: Node) -> bool:
	if not item or item is not Cookware:
		return false
	var target = contents.back()
	if target is Food and item._can_accept(target):
		return true
	return false


## Transfer food from Bench to another Cookware
## @param cookware: The Cookware to transfer food to
func transfer_request(player_cookware: Cookware) -> void:
	if ENetManager.is_host():
		player_cookware.put(take())
		_client_transfer.rpc(ENetManager.get_my_id())
		return
	_transfer_as_host.rpc_id(1, ENetManager.get_my_id())


## Host-side method to handle transfer requests from clients
## @param player_id: The id of the player who is transferring the food
@rpc("any_peer", "call_remote", "reliable")
func _transfer_as_host(player_id: int) -> void:
	if not ENetManager.is_host():
		return
	var player_cookware = GlobalScript.get_local_player_by_id(player_id).item_in_hand
	if not _can_transfer(player_cookware):
		return
	player_cookware.put(take())
	_client_transfer.rpc(player_id)


## Client-side method to transfer food between cookwares, called by host
## @param player_id: The id of the player who is transferring the food
@rpc("authority", "call_remote", "reliable")
func _client_transfer(player_id: int) -> void:
	var player_cookware = GlobalScript.get_local_player_by_id(player_id).item_in_hand
	if not _can_transfer(player_cookware):
		return
	player_cookware.put(take())


## Serve food from Cookware to Plate
## @param plate: The Plate to serve food to
## @param cookware: The Cookware holding the food
func served_on_plate_request(plate: Plate, cookware: Cookware) -> void:
	if cookware.is_empty():
		Debug.info("Cookware is empty, cannot serve")
		return
	if ENetManager.is_host():
		plate.add_list_items(cookware.take_all())
		_client_served_on_plate.rpc(ENetManager.get_my_id())
		return
	_served_on_plate_as_host.rpc_id(1, ENetManager.get_my_id())


## Host-side method to handle serve requests from clients
## @param player_id: The id of the player who is serving the food
@rpc("any_peer", "call_remote", "reliable")
func _served_on_plate_as_host(player_id: int) -> void:
	if not ENetManager.is_host():
		return
	var cookware = GlobalScript.get_local_player_by_id(player_id).item_in_hand
	if not cookware or not (cookware is Cookware) or cookware.is_empty():
		Debug.info("Player is not holding a cookware with food")
		return
	var plate = contents.back()
	if plate and plate is Plate and plate.is_ready():
		plate.add_list_items(cookware.take_all())
		_client_served_on_plate.rpc(player_id)


## Client-side method to serve food to plate, called by host
## @param player_id: The id of the player who is serving the food
@rpc("authority", "call_remote", "reliable")
func _client_served_on_plate(player_id: int) -> void:
	var cookware = GlobalScript.get_local_player_by_id(player_id).item_in_hand
	if not cookware or not (cookware is Cookware) or cookware.is_empty():
		Debug.info("Player is not holding a cookware with food")
		return
	var plate = contents.back()
	if plate and plate is Plate and plate.is_ready():
		plate.add_list_items(cookware.take_all())



## Give visual feedback when hovered
## @param is_hovered: Whether the item is hovered or not
func _on_interactable_component_hovered(is_hovered: bool) -> void:
	return
	# if not is_hovered:
	# 	highlight_component.hide_feedback()
	# 	return
	# var player = GlobalScript.get_local_player()
	# var item
	# if player:
	# 	item = player.item_in_hand
	
	# if item:
	# 	Debug.all("Player ID: " + str(ENetManager.get_my_id())
	# 		+ " has : " + item.get_script().get_global_name() + ", hovered: " + get_script().get_global_name())
	# if not item:
	# 	highlight_component.set_state(ApplianceHighlight.HighlightState.HOVER)
	# 	return
	# var can_accept = _can_accept(item)
	# highlight_component.show_feedback(can_accept)