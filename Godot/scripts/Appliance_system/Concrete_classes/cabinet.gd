## Cabinet is a type of appliance that allows players to place or take Plates.
## It does not perform any specific actions like cooking or processing.
class_name Cabinet
extends UnPoweredAppliance

# var item_slots: Array[Vector3] = []  ## Where to place items
var plate_scene: PackedScene = preload("res://scripts/order_system/Plate.tscn")

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/furniture/BasicBench.glb")


## Setup the Cabinet
func _ready():
	super._ready()
	capacity = 4
	# _setup_item_slots()
	if plate_scene and plate_scene.can_instantiate():
		print("Cabinet plate scene preloaded successfully")
	else:
		push_error("Failed to preload plate scene in Cabinet")
	for i in range(capacity):
		var plate = plate_scene.instantiate()
		add_child(plate)
		put(plate)


## Override upgradable setup in concrete appliances
func _setup_upgradable():
	super._setup_upgradable()
	enable_upgrade("capacity", [1, 1, 1], [80, 160, 240])


# ## Setup cookware slots, should be overridden by subclasses
# ## Default implementation expect one Cookware slot in the center
# func _setup_item_slots():
# 	for i in range(capacity):
# 		var slot_position = Vector3(0.0, size.y * 0.8, 0.0)
# 		item_slots.append(slot_position)


## Check if this appliance can accept the given item
## @param item: The Node to test for acceptance
## @return: True if item can be placed, false otherwise
func _can_accept(item: Node) -> bool:
	if not super._can_accept(item):
		return false
	return item is Plate and item.is_ready() # maybe we need different method to check clean and empty


## For Player interaction --------------------------------------------------------------------------

## Perform action depend on what player is holding
## @param _item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(item: Node) -> bool: # we may need player or id as parameter for multiplier!!!!!!!!!!!!!!!!!!
	# If player has nothing: move Plate from Cabinet to player (if exists), return true
	if not item:
		var plate = take()
		if plate:
			GlobalScript.player.pickup_item(plate)
			#----------------------------------------------------------------------
			print("Player took: ", plate.get_script().get_global_name(), ", from: ", get_script().get_global_name())
			#----------------------------------------------------------------------
			return true
		else:
			print("No plate to take from Cabinet")
			return false
	# If player has empty plate: depend on if cabinet can accept it
	return put_from_player(item)


## Give visual feedback when hovered
## @param is_hovered: Whether the item is hovered or not
func _on_interactable_component_hovered(is_hovered: bool) -> void:
	if not is_hovered:
		highlight_component.hide_feedback()
		return
	var item = GlobalScript.player.item_in_hand
	#---------------------------------------------------------------------------
	if item:
		print("Player has : ", item.get_script().get_global_name(), ", hovered: ", get_script().get_global_name())
	#---------------------------------------------------------------------------
	if not item:
		highlight_component.show_feedback(true)
		return
	var can_accept = _can_accept(item)
	highlight_component.show_feedback(can_accept)
#---------------------------------------------------------------------------------------------------


## Override unsupported methods to prevent misuse ------------------------------
func start_action() -> bool:
	assert(false, "Cabinet does not support starting actions")
	return false
#-------------------------------------------------------------------------------





