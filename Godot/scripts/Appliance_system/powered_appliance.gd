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


## Place an item onto this appliance
## @param item: The Node to place on this appliance
## @return: True if placement was successful, false otherwise
func put(item: Node) -> bool:
	if not _can_accept(item):
		return false
	contents.append(item)
	return true


## Remove and return the last item from this appliance
## @return: The Node that was removed, or null if nothing to take
func take() -> Node:
	if contents.is_empty():
		return null
	return contents.pop_back()


## Remove and return item at specific index
## @param index: Index of item to remove
## @return: The Node that was removed, or null if invalid index
func take_at(index: int) -> Node:
	if index < 0 or index >= contents.size():
		return null
	return contents.pop_at(index)


## Check if this appliance can accept the given item
## @param item: The Node to test for acceptance
## @return: True if item can be placed, false otherwise
func _can_accept(item: Node) -> bool:
	if current_status == Status.BROKEN:
		return false
	if contents.size() >= capacity:
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
