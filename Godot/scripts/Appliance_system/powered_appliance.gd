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
@export var valid_class_names: Array[String] = [] ## Class names that can be placed in (Recommended)
@export var valid_classes: Array[Script] = [] ## Class scripts that can be placed in (Fallback)
@export var cook_interval: float = 1.0 ## Cook every ? seconds

var current_status: Status = Status.IDLE
var contents: Array[Node] = []
var cook_timer: Timer
var power: int = 1


## Setup the PoweredAppliance
func _ready():
	super._ready()
	# Create and configure timer
	cook_timer = Timer.new()
	cook_timer.wait_time = cook_interval
	cook_timer.timeout.connect(_on_cook_timer_timeout)
	add_child(cook_timer)


## Add corresponding Cookware to the PoweredAppliance
## @param cookware_script_name: The script name of the cookware to add
func add_cookware(cookware_script_name: String):
	var cookware = ApplianceFactory.create_appliance(cookware_script_name)
	if not cookware:
		push_error("Failed to create cookware: " + cookware_script_name)
		return
	add_child(cookware)
	put(cookware)
	# Position and size cookware relative to appliance
	cookware.size = self.size * 0.6  # 60% of appliance size
	cookware.position = Vector3(0, size.y * 0.1, 0)  # Slightly above bottom


## Perform action depend on what player is holding
## @param _item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(item: Node) -> bool: # we may need player or id as parameter for multiplier!!!!!!!!!!!!!!!!!!

	# Let's ignore Blender and Freezer for now, all PoweredAppliance has 1 Cookware !!!!!!!!!

	# If player has nothing: move item from appliance to player (if exists), return true
	if not item:
		var cookware = take()
		if cookware:
			cookware.finish_cook()
			GlobalScript.player.pickup_item(cookware)
			if contents.is_empty():
				stop_cook()
			return true
		else:
			print("No cookware to take from PoweredAppliance")
			return false
	# If player has clean empty plate: serve food from Cookware, return true
	if item.is_class("Plate"):
		return serve_to_plate(item)
	# If item_in_hand exists: depend on if appliance can accept it
	return put(item)



func serve_to_plate(plate: Node) -> bool: # Node should change to Plate when its ready!!!!!!!!
	if contents.is_empty():
		push_warning("Nothing to serve")
		return false
	if not plate:
		push_warning("Cannot serve to null")
		return false
	if plate.has_method("is_ready"):
		if not plate.is_ready():
			push_warning("Cannot serve to non-ready plate") # maybe not empty? maybe dirty??
			return false
		var cookware = contents[0]
		# Method in MenuItem, takes Array and return subclass of MenuItem
		var dish = ApplianceFactory.match_menu_items(cookware.take_all())

		stop_cook()
		if plate.has_method("add_dish"):
			plate.add_dish(dish)
			print("Cookware served dish to plate: ", plate.name)
			return true

	push_warning("Plate does not provide required methods")
	return false



## Place an item onto this appliance
## @param item: The Node to place on this appliance
## @return: True if placement was successful, false otherwise
func put(item: Node) -> bool:
	if not _can_accept(item):
		return false
	contents.append(item)
	# transfer item to appliance
	if item.get_parent():
		item.get_parent().remove_child(item)
	add_child(item)
	return true


## Remove and return the last item from this appliance
## @return: The Node that was removed, or null if nothing to take
func take() -> Node:
	if contents.is_empty():
		return null
	var item = contents.pop_back()
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
		print("Cannot accept item, appliance is broken")
		return false
	if contents.size() >= capacity:
		print("Cannot accept item, appliance is at full capacity")
		return false
	return item.get_class() in valid_class_names or item.get_script() in valid_classes


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
	return true


## Perform cooking logic
## This method should be overridden in subclasses to implement specific cooking behavior
func _cook() -> bool:
	if current_status != Status.COOKING:
		assert(false, "Do not call cook() unless status is COOKING")
		return false

	for item in contents:
		if item is Cookware:
			item.cook(power)
		elif item.has_method("cook"): ## Check the method name!!!!!!!!!!!!!!!!!!!!!!!!
			item.cook(power, cooking_style)

	return true


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
