## Powered kitchen appliances that can cook food and have operational status
## Examples: stove, oven, fryer, blender, freezer
## If it has paired Cookware, it can only take one of that type (E.g. oven and pot)
class_name PoweredAppliance
extends Appliance

signal status_changed(new_status: Status)

enum Status {
	IDLE,
	COOKING,
	OFF,
	BROKEN
}

@export var capacity: int = 1 ## Maximum number of items this appliance can hold
@export var valid_classes: Array[String] = [] ## Class names that can be placed in (Recommended)
@export var cook_interval: float = 1.0 ## Cook every ? seconds

var current_status: Status = Status.IDLE
var contents: Array[Node] = []
var cook_timer: Timer
var power: int = 1
var cookware_slots: Array[Vector3] = []  ## Where to place cookware


## Setup the PoweredAppliance
func _ready():
	super._ready()
	_setup_cookware_slots()
	# Create and configure timer
	cook_timer = Timer.new()
	cook_timer.wait_time = cook_interval
	cook_timer.timeout.connect(_on_cook_timer_timeout)
	add_child(cook_timer)


## Setup cookware slots, should be overridden by subclasses
## Default implementation expect one Cookware slot in the center
func _setup_cookware_slots():
	var slot_position = Vector3(0.0, size.y * 0.5, 0.0)
	cookware_slots.append(slot_position)


## Apply position and direction to cookware at given slot
func _position_cookware(cookware: Cookware, slot_index: int):
	cookware.position = cookware_slots[slot_index]
	cookware.rotate_to_direction(cookware.default_facing)


## Add corresponding Cookware to the PoweredAppliance
## @param cookware_script_name: The script name of the cookware to add
func _add_cookware(cookware_script_name: String):
	var cookware = ApplianceFactory._create_appliance(cookware_script_name)
	if not cookware:
		push_error("Failed to create cookware: " + cookware_script_name)
		return
	put(cookware)
	# Position and size cookware relative to appliance
	_position_cookware(cookware, 0)


## Place an item onto this appliance
## @param item: The Node to place on this appliance
## @return: True if placement was successful, false otherwise
func put(item: Node) -> bool:
	if not _can_accept(item):
		return false
	# transfer item to appliance
	GlobalScript.player.remove_item() # if we only put item from players hand
	add_child(item)
	contents.append(item)
	#--------------------------------------------
	print("Put: ", item.get_script().get_global_name(), " onto: ", get_script().get_global_name())
	print("Contents of ", get_script().get_global_name(), " are: ")
	for content in contents:
		print(" --- ", content.get_script().get_global_name())
	#--------------------------------------------
	if item is Cookware:
		_put_cookware(item)
	return true


## Place a Cookware onto this PoweredAppliance, start cooking if applicable
## @param cookware: The Cookware to place on this PoweredAppliance
func _put_cookware(cookware: Cookware) -> void:
	_position_cookware(cookware, contents.size() - 1)
	cookware.lock()
	if not cookware.is_empty() and can_cook():
		cookware.cook(power)
		_set_status(Status.COOKING)


## Remove and return the last item from this appliance
## @return: The Node that was removed, or null if nothing to take
func take() -> Node:
	if contents.is_empty():
		return null
	var item = contents.pop_back()
	item.unlock()
	remove_child(item)
	return item


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
	if contents.size() >= capacity:
		print("Cannot accept item: ", get_script().get_global_name(), " is at full capacity")
		return false
	if not item.get_script():
		print("Cannot accept item, item has no script")
		return false
	# return item.get_script().get_global_name() in valid_classes
	#--------------------------------------------
	var accepted = item.get_script().get_global_name() in valid_classes
	if not accepted:
		print("Cannot accept : ", item.get_script().get_global_name())
	return accepted
	#--------------------------------------------


## Start cooking process
## @return: True if cooking started
func start_cook() -> bool:
	if current_status != Status.IDLE:
		return false
	if contents.is_empty():
		push_warning("No items to cook")
		return false
	current_status = Status.COOKING
	status_changed.emit(current_status)
	# cook_timer.start() let food handle the timer
	#----------------------------------------------------------------------
	print("start_cook() is called in: ", get_script().get_global_name())
	#----------------------------------------------------------------------
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
	current_status = Status.IDLE
	status_changed.emit(current_status)
	cook_timer.stop()
	#----------------------------------------------------------------------
	print("stop_cook() is called in: ", get_script().get_global_name())
	#----------------------------------------------------------------------
	return true


## Perform cooking logic
## This method should be overridden in subclasses to implement specific cooking behavior
func _cook() -> bool:
	if current_status != Status.COOKING:
		assert(false, "Do not call cook() unless status is COOKING")
		return false

	for item in contents:
		if item is Cookware:
			#----------------------------------------------------------------------
			print("Cooking with: ", item.get_script().get_global_name())
			#----------------------------------------------------------------------
			item.cook(power)

		# potentially need it for blender
		# elif item.has_method("cook"): ## Check the method name!!!!!!!!!!!!!!!!!!!!!!!!
		# 	item.cook(power, cooking_style)
	return true


## Check if this PoweredAppliance is empty
## @return: True if PoweredAppliance is empty, false otherwise
func is_empty() -> bool:
	return contents.is_empty()


## Check if this PoweredAppliance can cook
## @return: True if PoweredAppliance can cook, false otherwise
func can_cook() -> bool:
	return current_status == Status.COOKING or current_status == Status.IDLE


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
	return _set_status(Status.IDLE)


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
	return _set_status(Status.IDLE)


## Set the current status and emit signal
## @param new_status: The new status to set
## @return: always true
func _set_status(new_status: Status) -> bool:
	current_status = new_status
	status_changed.emit(new_status)
	cook_timer.stop()
	return true


## Timer callback to handle cooking logic
func _on_cook_timer_timeout():
	if current_status == Status.COOKING:
		_cook()
	else:
		cook_timer.stop()


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
			cookware.finish_cook()
			GlobalScript.player.pickup_item(cookware)
			#----------------------------------------------------------------------
			print("Player took: ", cookware.get_script().get_global_name(), ", from: ", get_script().get_global_name())
			#----------------------------------------------------------------------
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

	# If item_in_hand exists: depend on if appliance can accept it
	return put(item)



## Serve food from Cookware to Plate
## @param plate: The Plate to serve food to
## @return: True if serving was successful, false otherwise
func serve_to_plate(plate: Plate) -> bool: # Node should change to Plate when its ready!!!!!!!!
	if contents.is_empty():
		print("Nothing to serve from: ", get_script().get_global_name())
		return false

	# likely need to check if plate is ready here later!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	var cookware = contents[0]
	# Method in Plate, takes Array of Food
	if cookware.is_empty():
		print("Nothing to serve from: ", cookware.get_script().get_global_name())
		return false

	plate.add_list_items(cookware.take_all())
	stop_cook()
	#----------------------------------------------------------------------
	print("Cookware :", cookware.get_script().get_global_name(), ", served to: ", plate.name)
	#----------------------------------------------------------------------
	return true



# Functions for Sabotage System---------------------------------------------------------------------

## Get the current progress of cookwares
## Note: Only use it when PoweredAppliance can be operated
## Note: Progress is defined by the `cook_time` of `Food` -> smaller values are more progressed
## @return: The progress of the cooking process
func get_progress() -> int:
	if is_empty():
		return int(INF)
	var most_progress = INF
	for cookware in contents:
		if cookware.is_empty():
			continue
		most_progress = min(most_progress, cookware.average_food())
	return most_progress
#---------------------------------------------------------------------------------------------------
