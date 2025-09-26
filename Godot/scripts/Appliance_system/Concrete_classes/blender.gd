class_name Blender
extends PoweredAppliance

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/furniture/Blender.glb")


## Setup the blender properties
func _ready():
	super._ready()
	cooking_style = ApplianceFactory.CookingStyle.BLEND
	valid_classes = ["Tomato", "Water", "Milk", "Cocoa", "Flour", "Vanilla Icecream", "Strawberry"]
	capacity = 4
	power = 1
	add_to_group("Appliance")


## Override upgradable setup in concrete appliances
func _setup_upgradable():
	super._setup_upgradable()
	enable_upgrade("power", [1, 1, 1], [100, 200, 300])
	# enable_upgrade("capacity", [1, 1, 1], [80, 160, 240])


## Place an item onto this appliance
## @param item: The Node to place on this appliance
func _put(item: Node) -> void:
	contents.append(item)
	add_child(item)
	contents_names.append(item.name)
	_put_food(item) # Blender only takes Food


## Place an item onto this appliance
## @param item: The Node to place on this appliance
## @return: True if placement was successful, false otherwise
func put_all(items: Array) -> bool:
	if not _can_accept_all(items):
		return false
	for item in items:
		put(item)
	return true


## Place food into the blender
## @param food: The Food item to place into the blender
func _put_food(food: Food) -> void:
	#food.current_visibility(false)

	food.change_collisions(true)
	food_placed.emit()
	if current_status == Status.COOKING:
		_average_food()
		food.start_cooking(power, cooking_style)
	# print("Food placed in blender: ", food.get_script().get_global_name(), ", Food cook time: ", food.get_cook_time(cooking_style))


## Average cooking time of food in cookware
## Only subclass of Food should be in Cookware
## Note: Do not call when contents is empty (Food has different default cooking time)
## @return: The average cooking time of all food items in the cookware
func _average_food() -> float:
	if contents.size() == 1:
		return contents[0].get_cook_time(cooking_style)
	var total = 0.0
	for food in contents:
		total += food.get_cook_time(cooking_style)
	var average = total / contents.size()
	for food in contents:
		food.set_cook_time(average, cooking_style)
	return average


## Remove and return the last item from this appliance
## @return: The Node that was removed, or null if nothing to take
func take() -> Node:
	assert(false, "Use take_all() instead")
	return null


## Remove and return all items
## @return: Array of all items that were removed
func take_all() -> Array[Node]:
	var all_items = contents
	for item in all_items:
		remove_child(item)
	contents = []
	contents_names = []
	stop_cook()
	return all_items


## Check if this appliance can accept the all given items
## @param items: The Array of Nodes to test for acceptance
## @return: True if all items can be placed, false otherwise
func _can_accept_all(items: Array) -> bool:
	if items.is_empty():
		print("Cannot accept items, its empty")
		return false
	if contents.size() + items.size() > capacity:
		print("Cannot accept items: ", get_script().get_global_name(), " is at full capacity")
		return false
	for item in items:
		if not item.get_script().get_global_name() in valid_classes:
			return false
	return true


## Perform cooking logic
## Blender only takes Food
func _cook() -> bool:
	if is_empty():
		print("No food to blend")
		return false
	for food in contents:
		if food is Food:
			food.startCooking(power, cooking_style)
	return true


## Stop cooking process
## @return: True if cooking stopped
func stop_cook() -> bool:
	if current_status != Status.COOKING:
		push_warning("Cannot stop cooking unless appliance is cooking")
		return false
	for item in contents:
		if item is Food:
			item.stop_cooking()
	# #----------------------------------------------------------------------
	# print("stop_cook() is called in: ", get_script().get_global_name())
	# #----------------------------------------------------------------------
	return true


## For Player interaction --------------------------------------------------------------------------

## Perform action depend on what player is holding
## @param _item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(item: Node) -> void:
#--------------------------------------------
	print("Player has: ", item, ", Self: ", get_script().get_global_name())
#--------------------------------------------
	# If player has nothing, return false
	if not item:
		return
	# If player has plate: try to serve
	if item is Plate:
		serve_request(item)
		return
	# If player has cookware: try to transfer contents
	if item is Cookware:
		transfer_request(item)
		return
	# If item_in_hand exists: depend on if Blender can accept it
	put_request(item)


## Check if the plate can accept the current contents
## @param plate: The Node to check for acceptance
## @return: True if the plate can accept the current contents, false otherwise
func _check_plate(plate: Plate) -> bool:
	if is_empty():
		print("Nothing to serve from: ", get_script().get_global_name())
		return false
	if plate.is_ready():
		return true
	return false


## Serve food from Cookware to Plate
## @param plate: The Plate to serve food to
func serve_request(plate: Plate) -> void:
	# locally check first to reduce network calls
	if not _check_plate(plate):
		return
	if ENetManager.is_host():
		plate.add_list_items(take_all()) # Method in Plate, takes Array of Food
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
	plate.add_list_items(take_all()) # Method in Plate, takes Array of Food
	_client_serve.rpc(player_id)


## Client-side method to serve food to plate, called by host
## @param player_id: The id of the player who is serving the food
@rpc("authority", "call_remote", "reliable")
func _client_serve(player_id: int) -> void:
	var plate = GlobalScript.get_local_player_by_id(player_id).item_in_hand
	if plate and plate is Plate and _check_plate(plate):
		plate.add_list_items(take_all())


## Check if the cookware can accept the current contents
## @param cookware: The Node to check for acceptance
## @return: True if the cookware can accept the current contents, false otherwise
func _check_cookware(player_cookware: Node) -> bool:
	if not player_cookware or not (player_cookware is Cookware):
		print("Cookware is null or not a cookware")
		return false
	if is_empty():
		return _can_accept_all(player_cookware.show_contents())
	return player_cookware._can_accept_all(contents)


## Transfer food from Cookware to another Cookware
## @param cookware: The Cookware to transfer food to / from
func transfer_request(player_cookware: Cookware) -> void:
	# locally check first to reduce network calls
	if not _check_cookware(player_cookware):
		return
	if ENetManager.is_host():
		if is_empty():
			put_all(player_cookware.take_all())
			_client_transfer.rpc(ENetManager.get_my_id(), true)
			return
		player_cookware.put_all(take_all())
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
	if is_empty():
		put_all(player_cookware.take_all())
		_client_transfer.rpc(player_id, true)
		return
	player_cookware.put_all(take_all())
	_client_transfer.rpc(player_id, false)


## Client-side method to transfer food between cookwares, called by host
## @param player_id: The id of the player who is transferring the food
## @param taking: True if player is taking from appliance, false if giving to appliance
@rpc("authority", "call_remote", "reliable")
func _client_transfer(player_id: int, taking: bool) -> void:
	var player_cookware = GlobalScript.get_local_player_by_id(player_id).item_in_hand
	if not _check_cookware(player_cookware):
		return
	if taking:
		put_all(player_cookware.take_all())
	else:
		player_cookware.put_all(take_all())


## InteractableComponent Signal Handlers -----------------------------------------------------------
## Check if the target can accept the current contents
## @param target: The Node to check for acceptance
## @return: True if the target can accept the current contents, false otherwise
func _check_target(target: Node) -> bool:
	if is_empty():
		if target is Cookware:
			return _can_accept_all(target.show_contents())
		print("Nothing to serve from: ", get_script().get_global_name())
		return false
	if target is Plate and target.is_ready():
		# maybe check capacity here??? or no need? depend on how plate handle capacity
		return true
	if target is Cookware:
		return target._can_accept_all(contents)
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
		print("Player has : ", item.get_script().get_global_name(), ", hovered: ", get_script().get_global_name())
		print("Item name is:", item.name)
	#---------------------------------------------------------------------------
	if not item:
		highlight_component.set_state(ApplianceHighlight.HighlightState.HOVER)
		return
	if item is Plate or item is Cookware:
		highlight_component.show_feedback(_check_target(item))
		return
	highlight_component.show_feedback(_can_accept(item))
## -------------------------------------------------------------------------------------------------


# Functions for Sabotage System---------------------------------------------------------------------

## Get the current progress of cookwares
## Note: Only use it when PoweredAppliance can be operated
## Note: Progress is defined by the `cook_time` of `Food` -> smaller values are more progressed
## @return: The progress of the cooking process
func get_progress() -> float:
	if is_empty():
		return INF
	return _average_food()
#---------------------------------------------------------------------------------------------------


# # Non-networking methods for Player interaction ----------------------------------------------------
# ## Place an item onto this appliance
# ## @param item: The Node to place on this appliance
# ## @return: True if placement was successful, false otherwise
# func put_from_player(item: Node) -> bool:
# 	if not _can_accept(item):
# 		return false
# 	# transfer item to appliance
# 	GlobalScript.get_local_player().remove_item() # if we only put item from players hand
# 	add_child(item)
# 	contents.append(item)
# 	contents_names.append(item.name)
# 	if item is Food:
# 		_put_food(item)
# 	return true

# ## Serve food from Cookware to Plate
# ## @param plate: The Plate to serve food to
# ## @return: True if serving was successful, false otherwise
# func serve_to_plate(plate: Plate) -> bool:
# 	if not _check_target(plate):
# 		return false
# 	plate.add_list_items(take_all()) # Method in Plate, takes Array of Food
# 	return true
# #---------------------------------------------------------------------------------------------------
