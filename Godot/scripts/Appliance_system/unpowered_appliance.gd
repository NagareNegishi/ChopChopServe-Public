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
@export var valid_classes: Array[String] = [] ## Class names that can be placed in (Recommended)
# @export var valid_classes: Array[Script] = [] ## Class scripts that can be placed in (Fallback)
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
	#--------------------------------------------
	print("Put: ", item.get_script().get_global_name(), " onto: ", get_script().get_global_name())
	print("Contents of ", get_script().get_global_name(), " are: ")
	for content in contents:
		print(" --- ", content.get_script().get_global_name())
	#--------------------------------------------

	# transfer item to appliance
	GlobalScript.player.remove_item() # if we only put item from players hand
	# if item.get_parent():
	# 	item.get_parent().remove_child(item)
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
	if not item.get_script():
		print("Cannot accept item, item has no script")
		return false
	return item.get_script().get_global_name() in valid_classes


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
