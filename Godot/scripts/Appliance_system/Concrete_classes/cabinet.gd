## Cabinet is a type of appliance that allows players to place or take Plates.
## It does not perform any specific actions like cooking or processing.
class_name Cabinet
extends UnPoweredAppliance

# var item_slots: Array[Vector3] = []  ## Where to place items
var plate_scene: PackedScene = preload("res://scenes/Interaction/Plate.tscn")
var plate_count: int = 0

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/newmodels/furniture/BasicBench.glb")


## Setup the Cabinet
func _ready():
	super._ready()
	capacity = 300
	_set_affixes()
	capacity_upgradable.upgrade_completed.connect(_on_capacity_upgraded)
	# _setup_item_slots()
	if plate_scene and plate_scene.can_instantiate():
		Debug.all("Cabinet plate scene preloaded successfully")
	else:
		push_error("Failed to preload plate scene in Cabinet")
	for i in range(capacity):
		put(_provide_plate())


## Provide plate, register it with unique name
## @return: The Plate instance provided
func _provide_plate() -> Plate:
	var plate = plate_scene.instantiate()
	plate.name = prefix + plate.get_script().get_global_name() + str(supply_count)
	supply_count += 1
	plate_count += 1
	return plate


## Add synchronization properties for the placeable object
func _add_sync_properties(config: SceneReplicationConfig):
	super._add_sync_properties(config)
	config.add_property(NodePath(".:supply_count"))


## Override upgradable setup in concrete appliances
func _setup_upgradable():
	super._setup_upgradable()
	enable_upgrade("capacity", [1, 1, 1], [80, 160, 240])


## Add one more plate when capacity is upgraded
func _on_capacity_upgraded(property: String) -> void:
	if property == "capacity" and plate_count < capacity:
		put(_provide_plate())


## Check if this appliance can accept the given item
## @param item: The Node to test for acceptance
## @return: True if item can be placed, false otherwise
func _can_accept(item: Node) -> bool:
	if not super._can_accept(item):
		return false
	return item is Plate and item.is_ready() and item.is_empty()


## For Player interaction --------------------------------------------------------------------------

## Perform action depend on what player is holding
## @param _item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(item: Node) -> void:
	# If player has nothing: try to move Plate from Cabinet to player
	if not item:
		take_request()
		return
	# If player has empty plate: depend on if cabinet can accept it
	put_request(item)


## Give visual feedback when hovered
## @param is_hovered: Whether the item is hovered or not
func _on_interactable_component_hovered(is_hovered: bool) -> void:
	if not is_hovered:
		highlight_component.hide_feedback()
		return
	var item = GlobalScript.get_local_player().item_in_hand
	if item:
		Debug.all("Player ID: " + str(ENetManager.get_my_id())
			+ " has : " + item.get_script().get_global_name() + ", hovered: " + name)
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
