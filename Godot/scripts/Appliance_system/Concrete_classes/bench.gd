## Bench is a type of appliance that allows players to place or take items.
## It does not perform any specific actions like cooking or processing.
class_name Bench
extends UnPoweredAppliance

var item_slots: Array[Vector3] = []  ## Where to place items
var inflammable_component: Inflammable

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/furniture/BasicBench.glb")
	_setup_inflammable()


## Setup the bench
func _ready():
	super._ready()
	capacity = 1
	_setup_item_slots()


## Setup inflammable component
func _setup_inflammable():
	inflammable_component = Inflammable.new()
	add_child(inflammable_component)


## Setup cookware slots, should be overridden by subclasses
## Default implementation expect one Cookware slot in the center
func _setup_item_slots():
	for i in range(capacity):
		var slot_position = Vector3(0.0, size.y * 0.8, 0.0)
		item_slots.append(slot_position)


## Apply position and direction to item at given slot
func _position_item(item: Node, slot_index: int):
	if item is Cookware:
		item.restore_original_transform()
		item.rotate_to_direction(item.default_facing)
	item.position = item_slots[slot_index]



## Place an item onto this appliance
## @param item: The Node to place on this appliance
## @return: True if placement was successful, false otherwise
func put(item: Node) -> bool:
	if not super.put(item):
		return false
	_position_item(item, contents.size() - 1)
	return true


## Remove and return item at specific index
## @param index: Index of item to remove
## @return: The Node that was removed, or null if invalid index
func take_at(index: int) -> Node:
	if index < 0 or index >= contents.size():
		return null
	var item = contents.pop_at(index)
	remove_child(item)
	#--------------------------------------------
	print(item.get_script().get_global_name(), ", is taken from: ", get_script().get_global_name())
	#--------------------------------------------
	return item


## Take a food item from the bench
## @return: The Food item that was taken, or null if none found
func take_food() -> Food:
	for i in range(contents.size()):
		if contents[i] is Food:
			return take_at(i) as Food
	return null


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


## Override upgradable setup in concrete appliances
func _setup_upgradable():
	super._setup_upgradable()
	enable_upgrade("capacity", [1, 1, 1], [80, 160, 240])


## Handle fire event
func on_fire() -> void:
	current_status = Status.UNABLE
	for i in range(contents.size() - 1, -1, -1):
		var food = contents[i]
		if food is Food:
			contents.erase(food)
			remove_child(food)
			food.queue_free()


## Perform action depend on what player is holding
## @param _item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(item: Node) -> bool:
#--------------------------------------------
	print("Player has: ", item, ", Self: ", get_script().get_global_name())
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

	# If player has food: try to put it in Cookware
	if item is Food:
		for content in contents:
			if content is Cookware:
				return content.player_has(item)

	# If player has plate: try to serve food from Cookware
	if item is Plate and serve_to_plate(item):
		return true

	# If item_in_hand exists: depend on if appliance can accept it
	return put(item)


## Serve food from Cookware to Plate
## @param plate: The Plate to serve food to
## @return: True if serving was successful, false otherwise
func serve_to_plate(plate: Plate) -> bool:
	if contents.is_empty():
		print("Nothing to serve from: ", get_script().get_global_name())
		return false

	if not plate.is_ready(): # Method in Plate, checks if plate is ready
		print("Plate is not ready: ", plate.get_script().get_global_name())
		return false

	var cookware = contents[0]
	if not cookware is Cookware:
		print("Cannot serve from: ", cookware.get_script().get_global_name(), ", not Cookware")
		return false

	if cookware.is_empty():
		print("Nothing to serve from: ", cookware.get_script().get_global_name())
		return false

	print("Contents of : ", cookware.get_script().get_global_name(), " Before serving: ", cookware.contents)
	plate.add_list_items(cookware.take_all()) # Method in Plate, takes Array of Food
	#----------------------------------------------------------------------
	print("Contents of : ", cookware.get_script().get_global_name(), " After serving: ", cookware.contents)
	print("Cookware :", cookware.get_script().get_global_name(), ", served to: ", plate.get_script().get_global_name())
	#----------------------------------------------------------------------
	return true
