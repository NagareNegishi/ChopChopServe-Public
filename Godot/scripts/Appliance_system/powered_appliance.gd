## Powered kitchen appliances that can cook food and have operational status
## Examples: stove, oven, fryer, blender, freezer
class_name PoweredAppliance
extends Appliance

signal status_changed(new_status: Status)

enum Status {
	IDLE,
	COOKING,
	OFF,
	BROKEN
}

@export var capacity: int = 4 ## Maximum number of items this appliance can hold
@export var valid_classes: Array[Script] = [] ## Classes that can be placed in this appliance
@export var cook_interval: float = 1.0 ## Cook every ? seconds

# maybe redundant
# @export var accepts_equipment: bool = true ## Whether this appliance can accept equipment
# @export var accepts_food: bool = true ## Whether this appliance can accept food directly


var current_status: Status = Status.IDLE
var contents: Array[Node] = []
var cook_timer: Timer
var power: int = 1


func _ready():
	# Create and configure timer
	cook_timer = Timer.new()
	cook_timer.wait_time = cook_interval
	cook_timer.timeout.connect(_on_cook_timer_timeout)
	add_child(cook_timer)


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


# ## Remove and return first item of specific type
# ## @param item_class: Script class to look for
# ## @return: The Node that was removed, or null if not found
# func take_by_type(item_class: Script) -> Node:
# 	for i in range(contents.size()):
# 		if contents[i].get_script() == item_class:
# 			return contents.pop_at(i)
# 	return null


# ## Remove and return all items
# ## @return: Array of all items that were removed
# func take_all() -> Array[Node]:
# 	var all_items = contents.duplicate()
# 	contents.clear()
# 	return all_items


# ## Remove and return all items of specific type
# ## @param item_class: Script class to look for
# ## @return: Array of matching items that were removed
# func take_all_by_type(item_class: Script) -> Array[Node]:
# 	var matching_items: Array[Node] = []
# 	for i in range(contents.size() - 1, -1, -1):  # Reverse to avoid index issues
# 		if contents[i].get_script() == item_class:
# 			matching_items.append(contents.pop_at(i))
# 	return matching_items


## Check if this appliance can accept the given item
## @param item: The Node to test for acceptance
## @return: True if item can be placed, false otherwise
func _can_accept(item: Node) -> bool:
	if current_status == Status.BROKEN:
		return false
	if contents.size() >= capacity:
		return false

	# may need to check null script, but it depends on how food are implemented!!!!!!!

	return item.get_script() in valid_classes


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
	cook_timer.start()
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
		if item is Container:
			item.cook(power)
		elif item.has_method("cook"): ## Check the method name!!!!!!!!!!!!!!!!!!!!!!!!
			item.cook(power)

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
