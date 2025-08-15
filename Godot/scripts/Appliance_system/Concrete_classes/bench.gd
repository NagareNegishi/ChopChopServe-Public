## Bench is a type of appliance that allows players to place or take items.
## It does not perform any specific actions like cooking or processing.
class_name Bench
extends Appliance

@export var capacity: int = 4 ## Maximum number of items this appliance can hold
@export var valid_classes: Array[Script] = [] ## Classes that can be placed in this appliance

var contents: Array[Node] = []

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/furniture/BasicBench.glb")


## Setup the bench
func _ready():
	super._ready()


## Perform action depend on what player is holding
## @param _item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(_item: Node) -> bool:
	return false


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
	if contents.size() >= capacity:
		return false

	# may need to check null script, but it depends on how food are implemented!!!!!!!

	return item.get_script() in valid_classes