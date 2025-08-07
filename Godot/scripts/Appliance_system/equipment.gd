## Kitchen equipment class
## There are 2 types of equipment:
## 1. Container: Used by PoweredAppliance, like a Pot, Pan, etc.
## 2. Tool: Used with Appliance, like a Knife, Whisk, etc.
## Equipment must be used by PoweredAppliance or Player, it will not work alone
class_name Equipment
extends Appliance

signal status_changed(new_status: Status)

enum Status {
	IDLE,
	USING,
	BROKEN
	#, DIRTY ???
}

@export var coefficient: float = 1.0 ## Cooking efficiency modifier (1.0 = normal)
@export var capacity: int = 1 ## Maximum number of items this appliance can hold / deal with
@export var valid_classes: Array[Script] = [] ## Classes that can be placed in / use for

var current_status: Status = Status.IDLE
var contents: Array[Node] = []
var interactable_component: InteractableComponent


## Setup the equipment
func _ready():
	super._ready()
	setup_interactable()


## Add interactable component to this equipment
func setup_interactable():
	interactable_component = InteractableComponent.new()
	interactable_component.name = "InteractableComponent"
	add_child(interactable_component)
	# Connect signals if needed


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


## Remove and return all items
## @return: Array of all items that were removed
func take_all() -> Array[Node]:
	var all_items = contents.duplicate()
	contents.clear()
	return all_items


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


## Perform cooking logic
## This method should be overridden in subclasses to implement specific cooking behavior
## @param power: The power from PoweredAppliance or Player
func cook(_power: int) -> bool:
	assert(false, "cook() must be implemented in " + get_class())
	# if current_status != Status.COOKING:
	#     assert(false, "Do not call cook() unless status is COOKING")
	#     return false
	return true


## Finish cooking process
## @return: True if cooking finished
func finish_cook() -> bool:
	if current_status != Status.USING:
		push_warning("Cannot finish cooking unless appliance is using")
		return false
	current_status = Status.IDLE
	status_changed.emit(current_status)
	return true


## Check if this equipment can be used
## @return: True if equipment can be used, false if broken
func can_use() -> bool:
	return current_status == Status.IDLE


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
	return true