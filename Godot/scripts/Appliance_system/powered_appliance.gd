## Powered kitchen appliances that can cook food and have operational status
## Examples: stove, oven, fryer, blender, freezer
## If it has paired Cookware, it can only take one of that type (E.g. oven and pot)
class_name PoweredAppliance
extends Appliance

signal status_changed(new_status: Status)

enum Status {
	COOKING,
	OFF,
	BROKEN
}

@export_group("PoweredAppliance Settings")
@export var capacity: int = 1 ## Maximum number of items this appliance can hold
@export var valid_classes: Array[String] = [] ## Class names that can be placed in this appliance
@export var cook_interval: float = 1.0 ## Cook every ? seconds

var current_status: Status = Status.COOKING
var cook_timer: Timer
var power: int = 1
var cookware_slots: Array[Vector3] = []  ## Where to place cookware


## Setup the PoweredAppliance
func _ready():
	super._ready()
	_setup_cookware_slots()
	# _setup_cook_timer()


## Add synchronization properties for the placeable object
func _add_sync_properties(config: SceneReplicationConfig):
	super._add_sync_properties(config)
	config.add_property(NodePath(".:current_status"))
	config.add_property(NodePath(".:power"))
	config.add_property(NodePath(".:capacity"))


## Setup cookware slots, should be overridden by subclasses
## Default implementation expect one Cookware slot in the center
func _setup_cookware_slots():
	var slot_position = Vector3(0.0, size.y * 0.8, 0.0)
	cookware_slots.append(slot_position)


## Apply position and direction to cookware at given slot
func _position_cookware(cookware: Cookware, slot_index: int):
	cookware.position = cookware_slots[slot_index]
	cookware.rotate_to_direction(cookware.default_facing)


## Add corresponding Cookware to the PoweredAppliance
## @param cookware_script_name: The script name of the cookware to add
func _add_cookware(cookware_script_name: String):
	var cookware = ApplianceFactory._create_appliance(cookware_script_name)
	cookware.set_appliance_owner(current_owner)
	cookware.name = name + "_" + cookware_script_name
	ApplianceManager.register_appliance(cookware, current_owner, cookware.name)
	if not cookware:
		push_error("Failed to create cookware: " + cookware_script_name)
		return
	put(cookware)


## Place an item onto this appliance, if it can accept it
## @param item: The Node to place on this appliance
## @return: True if placement was successful, false otherwise
func put(item: Node) -> bool:
	if not _can_accept(item):
		return false
	_put(item)
	return true


## Place an item onto this appliance
## @param item: The Node to place on this appliance
func _put(item: Node) -> void:
	contents.append(item)
	add_child(item)
	contents_names.append(item.name)
	if item is Cookware:
		_put_cookware(item)


## Place a Cookware onto this PoweredAppliance, start cooking if applicable
## @param cookware: The Cookware to place on this PoweredAppliance
func _put_cookware(cookware: Cookware) -> void:
	cookware._toggle_interaction(false)
	cookware.restore_original_transform() # should be removed once player returns original scale !!!
	_position_cookware(cookware, contents.size() - 1)
	cookware.lock()
	cookware.set_can_use(true)
	cookware.power_receiving = power
	if cookware.can_cook() and can_cook():
		cookware.cook(power)


## Fallback method to put item with re-parenting
## @param item: The Node to place on this appliance
func _put_with_reparent(item: Node) -> void:
	contents.append(item)
	item.reparent(self)
	contents_names.append(item.name)
	if item is Cookware:
		_put_cookware(item)


## Client-side method to put item, called by host
## @param item_name: The name of the item to put
## @param player_id: The id of the player who is putting the item
@rpc("authority", "call_remote", "reliable")
func _client_put(item_name: String, player_id: int) -> void:
	# First try to find item in player's hand
	var player = GlobalScript.get_local_player_by_id(player_id)
	if player:
		var item = player.item_in_hand
		if item and item.name == item_name:
			player.remove_item()
			_put(item)
			return
	# If item not found in player's hand, try to find it in the current scene
	var missing_item = get_tree().current_scene.get_node_or_null(item_name)
	if missing_item:
		_put_with_reparent(missing_item)


## Remove and return the last item from this appliance
## @return: The Node that was removed, or null if nothing to take
func take() -> Node:
	if contents.is_empty() or contents_names.is_empty():
		return null
	var item = contents.pop_back()
	if item is Cookware:
		_take_cookware(item)
	remove_child(item)
	contents_names.pop_back()
	if contents.is_empty():
		stop_cook()
	return item


## Take cookware from this appliance
## @param cookware: The Cookware to take
func _take_cookware(cookware: Cookware) -> void:
	cookware.finish_cook()
	cookware.set_can_use(false)
	cookware.unlock()
	cookware.restore_original_transform()
	cookware._toggle_interaction(true)


## Client-side method to take item, called by host
## @param item_name: The name of the item to take
@rpc("authority", "call_remote", "reliable")
func _client_take(item_name: String) -> void:
	for i in range(contents.size()):
		if contents[i].name == item_name:
			var item = contents.pop_at(i)
			if item is Cookware:
				_take_cookware(item)
			remove_child(item)
			if contents.is_empty():
				stop_cook()
			get_tree().current_scene.add_child(item)
			break


## Check if this appliance can accept the given item
## @param item: The Node to test for acceptance
## @return: True if item can be placed, false otherwise
func _can_accept(item: Node) -> bool:
	if not item:
		print("Cannot accept item, item is null")
		return false
	if current_status == Status.BROKEN:
		print("Cannot accept item: ", get_script().get_global_name(), " is broken")
		return false
	if contents_names.size() >= capacity:
		# print("Cannot accept item: ", get_script().get_global_name(), " is at full capacity")
		return false
	if not item.get_script():
		print("Cannot accept item, item has no script")
		return false
	return item.get_script().get_global_name() in valid_classes


## Start cooking process
## @return: True if cooking started
func start_cook() -> bool:
	if current_status != Status.COOKING:
		return false
	if contents.is_empty():
		push_warning("No items to cook")
		return false
	# cook_timer.start()
	_cook()
	return true


## Stop cooking process
## @return: True if cooking stopped
func stop_cook() -> bool:
	if current_status != Status.COOKING:
		push_warning("Cannot stop cooking unless appliance is cooking")
		return false
	for item in contents:
		if item is Equipment:
			item.finish_cook()
	# cook_timer.stop()
	return true


## Perform cooking logic
## This method should be overridden in subclasses to implement specific cooking behavior
func _cook() -> bool:
	for item in contents:
		if item is Cookware:
			item.cook(power)
	return true


## Check if this PoweredAppliance is empty
## @return: True if PoweredAppliance is empty, false otherwise
func is_empty() -> bool:
	return contents.is_empty()


## Check if this PoweredAppliance is full
## @return: True if PoweredAppliance is full, false otherwise
func is_full() -> bool:
	return contents.size() >= capacity


## Check if this PoweredAppliance can cook
## @return: True if PoweredAppliance can cook, false otherwise
func can_cook() -> bool:
	return current_status == Status.COOKING


## Set the current status to broken
## @return: True if status was changed, it will always true
func broken() -> bool:
	return _set_status(Status.BROKEN)


## Set the current status to idle
## @return: True if status was changed
func repair() -> bool:
	if current_status != Status.BROKEN:
		push_warning("Cannot repair unless appliance is broken")
		return false
	return _set_status(Status.COOKING)


## Set the current status to off
## Automatically stop cooking if applicable
## @return: True if status was changed
func power_off() -> bool:
	if current_status == Status.BROKEN or current_status == Status.OFF:
		return false
	stop_cook()
	return _set_status(Status.OFF)


## Set the current status to cooking
## Automatically start cooking if applicable
## @return: True if status was changed
func power_on() -> bool:
	if current_status != Status.OFF:
		return false
	start_cook()
	return _set_status(Status.COOKING)


## Set the current status and emit signal
## @param new_status: The new status to set
## @return: always true
func _set_status(new_status: Status) -> bool:
	current_status = new_status
	status_changed.emit(new_status)
	# cook_timer.stop()
	return true


# Current implementation uses timer in Food, but keep it for future improvements -------------------
## Setup cooking timer
func _setup_cook_timer():
	cook_timer = Timer.new()
	cook_timer.wait_time = cook_interval
	cook_timer.timeout.connect(_on_cook_timer_timeout)
	add_child(cook_timer)

## Timer callback to handle cooking logic
func _on_cook_timer_timeout():
	if current_status == Status.COOKING:
		_cook()
	else:
		cook_timer.stop()
#---------------------------------------------------------------------------------------------------



## For Player interaction --------------------------------------------------------------------------

## Perform action depend on what player is holding
## @param _item: The Node Player is holding
func player_has(item: Node) -> void:
#--------------------------------------------
	print("Player with ID: ", ENetManager.get_my_id(), " has : ", item, ", Self: ", get_script().get_global_name())
#--------------------------------------------
	# If player has nothing: move item from appliance to player (if exists), return true
	if not item:
		take_request()
		return
	# If player has plate: try to serve food from Cookware
	if item is Plate:
		serve_request(item)
		return
	# If player has food: try to put it in Cookware
	if item is Food:
		contents[0].player_has(item)
		return
	# If player has cookware: try to transfer contents
	if item is Cookware and not is_empty():
		transfer_request(item)
		return
	# If item_in_hand exists: depend on if appliance can accept it
	put_request(item)


## Request to put an item onto this appliance from Player
## @param item: The Node to place on this appliance
func put_request(item: Node) -> void:
	# locally check first to reduce network calls
	if not _can_accept(item):
		return
	# host directly put item and notify clients
	if ENetManager.is_host():
		GlobalScript.get_local_player().remove_item()
		_put(item)
		_client_put.rpc(item.name, ENetManager.get_my_id())
		_sync_contents.rpc(contents_names)
		return
	_put_as_host.rpc_id(1, ENetManager.get_my_id(), item.name)


## Host-side method to handle put requests from clients
## @param player_id: The id of the player who is putting the item
## @param item_name: The name of the item to put
@rpc("any_peer", "call_remote", "reliable")
func _put_as_host(player_id: int, item_name: String) -> void:
	if not ENetManager.is_host():
		return
	# host need check to prevent conflicts/ cheating
	var player = GlobalScript.get_local_player_by_id(player_id)
	if not player:
		print("Player not found with id: ", player_id)
		return
	var item = player.item_in_hand
	if not _can_accept(item):
		return
	if item.name != item_name:
		print("Item name mismatch: expected ", item_name, ", got ", item.name)
		return
	player.remove_item()
	_put(item)
	_client_put.rpc(item.name, player_id)
	_sync_contents.rpc(contents_names)


## Request to take an item from this appliance to Player
func take_request() -> void:
	# locally check first to reduce network calls
	if contents.is_empty() or contents_names.is_empty():
		return
	_take_as_host.rpc_id(1, ENetManager.get_my_id())


## Host-side method to handle take requests from clients
## @param player_id: The id of the player who is taking the item
@rpc("any_peer", "call_local", "reliable")
func _take_as_host(player_id: int) -> void:
	if not ENetManager.is_host():
		return
	# host need check to prevent conflicts/ cheating
	if contents.is_empty() or contents_names.is_empty():
		return
	var item = take()
	get_tree().current_scene.add_child(item)
	_client_take.rpc(item.name)
	_give_item_to_player.rpc(player_id, item.get_path())
	_sync_contents.rpc(contents_names)


## Client-side method to give item to player, called by host
## @param player_id: The id of the player who is taking the item
## @param item_path: The NodePath of the item to give
@rpc("authority", "call_local", "reliable")
func _give_item_to_player(player_id: int, item_path: NodePath) -> void:
	var item = get_node_or_null(item_path)
	if item:
		var player = GlobalScript.get_local_player_by_id(player_id)
		if player:
			player.pickup_item(item)


## Sync contents names across network
## @param update: The updated contents names array
@rpc("authority", "call_remote", "reliable")
func _sync_contents(update: Array[String]) -> void:
	contents_names = update


## Check if the plate can accept the current contents
## @param plate: The Node to check for acceptance
## @return: True if the plate can accept the current contents, false otherwise
func _check_plate(plate: Plate) -> bool:
	if is_empty():
		print("Nothing to serve from: ", get_script().get_global_name())
		return false
	if plate.is_ready() and not contents[0].is_empty():
		return true
	return false


## Serve food from Cookware to Plate
## @param plate: The Plate to serve food to
func serve_request(plate: Plate) -> void:
	# locally check first to reduce network calls
	if not _check_plate(plate):
		return
	if ENetManager.is_host():
		plate.add_list_items(contents[0].take_all()) # Method in Plate, takes Array of Food
		_client_serve.rpc(ENetManager.get_my_id())
		return
	_serve_as_host.rpc_id(1, ENetManager.get_my_id())


## Host-side method to handle serve requests from clients
## @param player_id: The id of the player who is serving the food
@rpc("any_peer", "call_remote", "reliable")
func _serve_as_host(player_id: int) -> void:
	if not ENetManager.is_host():
		return
	var plate = GlobalScript.get_local_player_by_id(player_id).item_in_hand
	if not plate or not (plate is Plate):
		print("Player is not holding a plate")
		return
	if not _check_plate(plate):
		return
	plate.add_list_items(contents[0].take_all()) # Method in Plate, takes Array of Food
	_client_serve.rpc(player_id)


## Client-side method to serve food to plate, called by host
## @param player_id: The id of the player who is serving the food
@rpc("authority", "call_remote", "reliable")
func _client_serve(player_id: int) -> void:
	var plate = GlobalScript.get_local_player_by_id(player_id).item_in_hand
	if plate and plate is Plate and _check_plate(plate):
		plate.add_list_items(contents[0].take_all())


## Check if the cookware can accept the current contents
## @param cookware: The Node to check for acceptance
## @return: True if the cookware can accept the current contents, false otherwise
func _check_cookware(player_cookware: Node) -> bool:
	if not player_cookware or not (player_cookware is Cookware):
		print("Cookware is null or not a cookware")
		return false
	if is_empty():
		print("Nothing to serve from: ", get_script().get_global_name())
		return false
	var appliance_cookware = contents[0]
	if appliance_cookware.is_empty():
		return appliance_cookware._can_accept_all(player_cookware.show_contents())
	return player_cookware._can_accept_all(appliance_cookware.show_contents())


## Transfer food from Cookware to another Cookware
## @param cookware: The Cookware to transfer food to / from
func transfer_request(player_cookware: Cookware) -> void:
	# locally check first to reduce network calls
	if not _check_cookware(player_cookware):
		return
	if ENetManager.is_host():
		var appliance_cookware = contents[0]
		if appliance_cookware.is_empty():
			appliance_cookware.put_all(player_cookware.take_all())
			_client_transfer.rpc(ENetManager.get_my_id(), true)
			return
		player_cookware.put_all(appliance_cookware.take_all())
		_client_transfer.rpc(ENetManager.get_my_id(), false)
		return
	_transfer_as_host.rpc_id(1, ENetManager.get_my_id())


## Host-side method to handle transfer requests from clients
## @param player_id: The id of the player who is transferring the food
@rpc("any_peer", "call_remote", "reliable")
func _transfer_as_host(player_id: int) -> void:
	if not ENetManager.is_host():
		return
	var player_cookware = GlobalScript.get_local_player_by_id(player_id).item_in_hand
	if not _check_cookware(player_cookware):
		return
	var appliance_cookware = contents[0]
	if appliance_cookware.is_empty():
		appliance_cookware.put_all(player_cookware.take_all())
		_client_transfer.rpc(player_id, true)
		return
	player_cookware.put_all(appliance_cookware.take_all())
	_client_transfer.rpc(player_id, false)


## Client-side method to transfer food between cookwares, called by host
## @param player_id: The id of the player who is transferring the food
## @param taking: True if player is taking from appliance, false if giving to appliance
@rpc("authority", "call_remote", "reliable")
func _client_transfer(player_id: int, taking: bool) -> void:
	var player_cookware = GlobalScript.get_local_player_by_id(player_id).item_in_hand
	if not _check_cookware(player_cookware):
		return
	var appliance_cookware = contents[0]
	if taking:
		appliance_cookware.put_all(player_cookware.take_all())
	else:
		player_cookware.put_all(appliance_cookware.take_all())


## Check if the target can accept the current contents
## @param target: The Node to check for acceptance
## @return: True if the target can accept the current contents, false otherwise
func _check_target(target: Node) -> bool:
	if is_empty():
		print("Nothing to serve from: ", get_script().get_global_name())
		return false
	if target is Plate and target.is_ready():
		if contents[0].is_empty():
			return false
		# maybe check capacity here??? or no need? depend on how plate handle capacity
		return true
	if target is Cookware:
		var cookware = contents[0]
		if cookware.is_empty():
			return cookware._can_accept_all(target.show_contents())
		return target._can_accept_all(cookware.show_contents())
	return false


## Give visual feedback when hovered
## @param is_hovered: Whether the item is hovered or not
func _on_interactable_component_hovered(is_hovered: bool) -> void:
	if not is_hovered:
		highlight_component.hide_feedback()
		return
	var item = GlobalScript.get_local_player().item_in_hand
	#---------------------------------------------------------------------------
	if item:
		print("Player has : ", item.get_script().get_global_name(), ", hovered: ", get_script().get_global_name(), ", Item name is:", item.name)
	#---------------------------------------------------------------------------
	if not item:
		highlight_component.set_state(ApplianceHighlight.HighlightState.HOVER)
		return
	if item is Plate or item is Cookware:
		highlight_component.show_feedback(_check_target(item))
		return
	var can_accept = _can_accept(item)
	if not can_accept:
		for cookware in contents:
			can_accept = cookware._can_accept(item)
	highlight_component.show_feedback(can_accept)
## -------------------------------------------------------------------------------------------------


# Functions for Sabotage System---------------------------------------------------------------------

## Get the current progress of cookwares
## Note: Only use it when PoweredAppliance can be operated
## Note: Progress is defined by the `cook_time` of `Food` -> smaller values are more progressed
## @return: The progress of the cooking process
func get_progress() -> float:
	if is_empty():
		return INF
	var most_progress = INF
	for cookware in contents:
		if cookware.is_empty():
			continue
		most_progress = min(most_progress, cookware._average_food())
	return most_progress
#---------------------------------------------------------------------------------------------------


# Non-networking methods for Player interaction ----------------------------------------------------
# ## Place an item onto this appliance from Player
# ## if we could remove Player dependency from this class, we can remove this method
# ## @param item: The Node to place on this appliance
# ## @return: True if placement was successful, false otherwise
# func put_from_player(item: Node) -> bool:
# 	if not _can_accept(item):
# 		return false
# 	# transfer item to appliance
# 	GlobalScript.get_local_player().remove_item()
# 	contents.append(item)
# 	add_child(item)
# 	contents_names.append(item.name)
# 	if item is Cookware:
# 		_put_cookware(item)
# 	return true

# ## Serve food from Cookware to Plate
# ## @param plate: The Plate to serve food to
# ## @return: True if serving was successful, false otherwise
# func serve_to_plate(plate: Plate) -> bool:
# 	if not _check_target(plate):
# 		return false
# 	var cookware = contents[0]
# 	if cookware.is_empty():
# 		print("Nothing to serve from: ", cookware.get_script().get_global_name())
# 		return false
# 	plate.add_list_items(cookware.take_all()) # Method in Plate, takes Array of Food
# 	return true
#---------------------------------------------------------------------------------------------------
