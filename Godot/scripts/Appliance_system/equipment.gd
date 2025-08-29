## Kitchen equipment class
## There are 2 types of equipment:
## 1. Container: Used by PoweredAppliance, like a Pot, Pan, etc.
## 2. Tool: Used with Appliance, like a Knife, Whisk, etc.
## Equipment must be used by PoweredAppliance or Player, it will not work alone
class_name Equipment
extends Appliance


@export_group("Equipment Settings")
@export var coefficient: float = 1.0 ## Cooking efficiency modifier (1.0 = normal)
@export var capacity: int = 1 ## Maximum number of items this appliance can hold / deal with
@export var valid_food: Array[String] = [] ## Class names that can be placed in this equipment

var contents: Array[Node] = []
var can_use: bool = false


## Setup the equipment
func _ready():
	super._ready()


## Place an item onto this appliance
## @param item: The Node to place on this appliance
## @return: True if placement was successful, false otherwise
func put(item: Node) -> bool:
	if not _can_accept(item):
		return false
	contents.append(item)
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


## Remove and return all items
## @return: Array of all items that were removed
func take_all() -> Array[Node]:
	var all_items = contents
	for item in all_items:
		remove_child(item)
	contents = []
	return all_items


## Check if this appliance can accept the given item
## @param item: The Node to test for acceptance
## @return: True if item can be placed, false otherwise
func _can_accept(item: Node) -> bool:
	if not item:
		print("Cannot accept item, item is null")
		return false
	if contents.size() >= capacity:
		print("Cannot accept item: ", get_script().get_global_name(), " is at full capacity")
		return false
	if not item.get_script():
		print("Cannot accept item, item has no script")
		return false
	return item.get_script().get_global_name() in valid_food
	# #--------------------------------------------
	# var accepted = item.get_script().get_global_name() in valid_food
	# if not accepted:
	# 	print("Cannot accept : ", item.get_script().get_global_name())
	# return accepted
	# #--------------------------------------------


## Perform cooking logic
## This method should be overridden in subclasses to implement specific cooking behavior
## @param power: The power from PoweredAppliance or Player
func cook(_power: int) -> bool:
	assert(false, "cook() must be implemented in " + get_class())
	return true


## Finish cooking process
## @return: True if cooking finished
func finish_cook() -> bool:
	if is_empty():
		return false
	for item in contents:
		if item is Food:
			item.stop_cooking()
	# #----------------------------------------------------------------------
	# 		print("stop_cooking() is called in: ", item.get_script().get_global_name())
	# #----------------------------------------------------------------------
	return true


## Check if this equipment is empty
## @return: True if equipment is empty, false otherwise
func is_empty() -> bool:
	return contents.is_empty()


## Check if this equipment is full
## @return: True if equipment is full, false otherwise
func is_full() -> bool:
	return contents.size() >= capacity


## Check if this equipment can be used
## @return: True if equipment can be used, false otherwise
func can_cook() -> bool:
	return can_use and not is_empty()


## Set the can_use property, Appliance use only
## @param value: True if equipment can be used, false otherwise
func set_can_use(value: bool):
	can_use = value


## For Player interaction --------------------------------------------------------------------------

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
	return true


## Perform action depend on what player is holding
## @param _item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(item: Node) -> bool: # we may need player or id as parameter for multiplier!!!!!!!!!!!!!!!!!!
	# If player has nothing: let them take self, return true
	if not item:
		GlobalScript.player.pickup_item(self)
		return true
	# If item_in_hand exists: depend on if equipment can accept it
	return put_from_player(item)
## -------------------------------------------------------------------------------------------------