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


## Place an item onto this appliance
## @param item: The Node to place on this appliance
## @return: True if placement was successful, false otherwise
func put(item: Node) -> bool:
	if not _can_accept(item):
		return false
	contents.append(item)
	add_child(item)
#-------------------------------------------------------------------------------
	contents_names.append(item.name)
#-------------------------------------------------------------------------------
	if item is Cookware:
		_put_cookware(item)
	return true


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


## Remove and return the last item from this appliance
## @return: The Node that was removed, or null if nothing to take
func take() -> Node:
	if contents.is_empty():
		return null
	var item = contents.pop_back()
#-------------------------------------------------------------------------------
	if not contents_names.is_empty():
		contents_names.pop_back()
#-------------------------------------------------------------------------------
	if item is Cookware:
		_take_cookware(item)
	remove_child(item)
	return item


## Take cookware from this appliance
## @param cookware: The Cookware to take
func _take_cookware(cookware: Cookware) -> void:
	cookware.finish_cook()
	cookware.set_can_use(false)
	cookware.unlock()
	cookware.restore_original_transform()
	cookware._toggle_interaction(true)


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
		print("Cannot accept item: ", get_script().get_global_name(), " is at full capacity")
		return false
	if not item.get_script():
		print("Cannot accept item, item has no script")
		return false
	return item.get_script().get_global_name() in valid_classes
	# #--------------------------------------------
	# var accepted = item.get_script().get_global_name() in valid_classes
	# if not accepted:
	# 	print("Cannot accept : ", item.get_script().get_global_name())
	# return accepted
	# #--------------------------------------------


## Start cooking process
## @return: True if cooking started
func start_cook() -> bool:
	if current_status != Status.COOKING:
		return false
	if contents.is_empty():
		push_warning("No items to cook")
		return false
	# cook_timer.start()
	# #----------------------------------------------------------------------
	# print("start_cook() is called in: ", get_script().get_global_name())
	# #----------------------------------------------------------------------
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
	# #----------------------------------------------------------------------
	# print("stop_cook() is called in: ", get_script().get_global_name())
	# #----------------------------------------------------------------------
	return true


## Perform cooking logic
## This method should be overridden in subclasses to implement specific cooking behavior
func _cook() -> bool:
	for item in contents:
		if item is Cookware:
			# #----------------------------------------------------------------------
			# print("Cooking with: ", item.get_script().get_global_name())
			# #----------------------------------------------------------------------
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
## @return: True if status was changed
func power_off() -> bool:
	if current_status == Status.BROKEN:
		return false
	return _set_status(Status.OFF)


## Set the current status to idle
## @return: True if status was changed
func power_on() -> bool:
	if current_status == Status.BROKEN:
		return false
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

func put_request(item: Node) -> void:
	if not _can_accept(item):
		return
	_put_as_host.rpc_id(1, ENetManager.get_peer_id(), item.name)

@rpc("any_peer", "call_local", "reliable")
func _put_as_host(player_id: int, item_name: String) -> void:
	pass

## Place an item onto this appliance from Player
## if we could remove Player dependency from this class, we can remove this method
## @param item: The Node to place on this appliance
## @return: True if placement was successful, false otherwise
func put_from_player(item: Node) -> bool:
	if not _can_accept(item):
		return false
	# transfer item to appliance
	GlobalScript.player.remove_item()
	contents.append(item)
	add_child(item)
#-------------------------------------------------------------------------------
	contents_names.append(item.name)
#-------------------------------------------------------------------------------
	#--------------------------------------------
	print("Put: ", item.get_script().get_global_name(), " onto: ", get_script().get_global_name())
	print("Contents of ", get_script().get_global_name(), " are: ")
	for content in contents:
		print(" --- ", content.get_script().get_global_name())
	#--------------------------------------------
	if item is Cookware:
		_put_cookware(item)
	return true


## Perform action depend on what player is holding
## @param _item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(item: Node) -> bool: # we may need player or id as parameter for multiplier!!!!!!!!!!!!!!!!!!
#--------------------------------------------
	print("Player has: ", item, ", Self: ", get_script().get_global_name())
#--------------------------------------------
	# If player has nothing: move item from appliance to player (if exists), return true
	if not item:
		var cookware = take()
		if cookware:
			print("Path before pickup: ", cookware.get_path())

			get_tree().current_scene.add_child(cookware)
			print("Path when at scene root: ", cookware.get_path())

			GlobalScript.player.pickup_item(cookware)
			print("Path after pickup: ", cookware.get_path())
			# #----------------------------------------------------------------------
			# print("Player took: ", cookware.get_script().get_global_name(), ", from: ", get_script().get_global_name())
			# #----------------------------------------------------------------------
			if contents.is_empty():
				stop_cook()
			return true
		else:
			print("No cookware to take from PoweredAppliance")
			return false

	# If player has plate: try to serve food from Cookware
	if item is Plate:
		return serve_to_plate(item)

	# If player has food: try to put it in Cookware
	if item is Food:
		for content in contents:
			if content is Cookware:
				return content.player_has(item)

	# If player has cookware: try to transfer contents
	if item is Cookware and not is_empty():
		var cookware = contents[0]
		if cookware.is_empty() and cookware._can_accept_all(item.show_contents()):
			return cookware.put_all(item.take_all())
		if item._can_accept_all(cookware.show_contents()):
			return item.put_all(cookware.take_all())

	# If item_in_hand exists: depend on if appliance can accept it
	return put_from_player(item)


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



## Serve food from Cookware to Plate
## @param plate: The Plate to serve food to
## @return: True if serving was successful, false otherwise
func serve_to_plate(plate: Plate) -> bool:
	if not _check_target(plate):
		return false
	# if is_empty():
	# 	print("Nothing to serve from: ", get_script().get_global_name())
	# 	return false

	# if not plate.is_ready(): # Method in Plate, checks if plate is ready
	# 	print("Plate is not ready: ", plate.get_script().get_global_name())
	# 	return false

	var cookware = contents[0]
	if cookware.is_empty():
		print("Nothing to serve from: ", cookware.get_script().get_global_name())
		return false

	#cookware.finish_cook()
	# print("Contents of : ", cookware.get_script().get_global_name(), " Before serving: ", cookware.contents)
	plate.add_list_items(cookware.take_all()) # Method in Plate, takes Array of Food
	# #----------------------------------------------------------------------
	# print("Contents of : ", cookware.get_script().get_global_name(), " After serving: ", cookware.contents)
	# print("Cookware :", cookware.get_script().get_global_name(), ", served to: ", plate.get_script().get_global_name())
	# #----------------------------------------------------------------------
	return true


## Give visual feedback when hovered
## @param is_hovered: Whether the item is hovered or not
func _on_interactable_component_hovered(is_hovered: bool) -> void:
	if not is_hovered:
		highlight_component.hide_feedback()
		return
	var item = GlobalScript.player.item_in_hand
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

