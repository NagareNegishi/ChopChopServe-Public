## Unpowered kitchen appliances that cannot cook food
## Examples: Bench, Sink, Trash Can, Food Crate
class_name UnPoweredAppliance
extends Appliance

signal status_changed(new_status: Status)


# can it be on fire????? or broken?????
enum Status {
	IDLE,
	USING,
	BROKEN
}

@export var capacity: int = 4 ## Maximum number of items this appliance can hold
@export var valid_classes: Array[Script] = [] ## Classes that can be placed in this appliance
@export var action_interval: float = 1.0 ## action every ? seconds


var current_status: Status = Status.IDLE
var contents: Array[Node] = []
var action_timer: Timer


func _ready():
	super._ready()
	# Create and configure timer
	action_timer = Timer.new()
	action_timer.wait_time = action_interval
	action_timer.timeout.connect(_on_action_timer_timeout)
	add_child(action_timer)


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

	# may need to check null script, but it depends on how food are implemented!!!!!!!

	return item.get_script() in valid_classes


## Start action process, and unable further actions until it completes
## Subclasses may wrap this method with intuitive name to implement specific action behavior
## @return: True if action started
func start_action() -> bool:
	if current_status != Status.IDLE:
		return false
	if contents.is_empty():
		push_warning("No items to act on")
		return false
	current_status = Status.USING
	status_changed.emit(current_status)
	action_timer.start()
	return _action()


## Perform action logic
## This method should be overridden in subclasses to implement specific action behavior
func _action() -> bool:
	assert(false, "action() must be implemented in " + get_class())
	return false
	# if current_status != Status.USING:
	#     assert(false, "Do not call action() unless status is USING")
	#     return false



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


## Set the current status and emit signal
## @param new_status: The new status to set
## @return: always true
func _set_status(new_status: Status) -> bool:
	current_status = new_status
	status_changed.emit(new_status)
	action_timer.stop()
	return true


## Timer callback to handle action logic
func _on_action_timer_timeout():
	current_status = Status.IDLE
	status_changed.emit(current_status)
	action_timer.stop()
