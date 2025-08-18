## Bench is a type of appliance that allows players to place or take items.
## It does not perform any specific actions like cooking or processing.
class_name Bench
extends UnPoweredAppliance


## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/furniture/BasicBench.glb")


## Setup the bench
func _ready():
	super._ready()
	#capacity = 4


## Perform action depend on what player is holding
## @param _item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(item: Node) -> bool:
#--------------------------------------------
	print("Player is holding: ", item)
	print("Player.item_in_hand: ", GlobalScript.player.item_in_hand)
	print("Self: ", get_script().get_global_name())
#--------------------------------------------
	# If player has nothing: move item from appliance to player (if exists), return true
	if not item:
		var taken = take()
		if taken:
			GlobalScript.player.pickup_item(taken)
			#----------------------------------------------------------------------
			print("Player took: ", taken.get_script().get_global_name(), ", from: ", get_script().get_global_name())
			#----------------------------------------------------------------------
			return true
		else:
			print("Nothing to take from Bench")
			return false
	# If item_in_hand exists: depend on if appliance can accept it
	return put(item)


## Remove and return item at specific index
## @param index: Index of item to remove
## @return: The Node that was removed, or null if invalid index
func take_at(index: int) -> Node:
	if index < 0 or index >= contents.size():
		return null
	var item = contents.pop_at(index)
	remove_child(item)
	return item


## Check if this appliance can accept the given item
## @param item: The Node to test for acceptance
## @return: True if item can be placed, false otherwise
func _can_accept(item: Node) -> bool:
	var acceptable = super._can_accept(item)
	if not acceptable:
		return false
	# return item is Food or item is Equipment or item is Plate
	#--------------------------------------------
	var accepted = item is Food or item is Equipment or item is Plate
	if not accepted:
		print("Cannot accept : ", item.get_script().get_global_name())
	return accepted
	#--------------------------------------------


## Override unsupported methods to prevent misuse ------------------------------
func start_action() -> bool:
	assert(false, "Bench does not support starting actions")
	return false
#-------------------------------------------------------------------------------