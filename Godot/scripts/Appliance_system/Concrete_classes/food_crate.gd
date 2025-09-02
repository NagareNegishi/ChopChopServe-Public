## Food Crate only provides a one type of ingredient, but takes nothing back.
## player can take food from food crate manually,
##
## Note: the implementation can be simplify by extending Appliance directly,
## however, considering the future extension, I will extend UnPoweredAppliance
class_name FoodCrate
extends UnPoweredAppliance

@export_group("Supply Settings")
@export var supply: PackedScene
@export var supply_name: String = "Tomato" # "Water"
var food_directory: String = "res://scripts/Food/IngredientScenes/"
var supply_instance: Node


## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/NuFurniture/FoodCrater.glb")


## Set up the FoodCrate
func _ready():
	super._ready()
	action_interval = 0.5 # small interval to avoid rapid item taking
	_set_affixes()
	_initialize_supply()


## Add synchronization properties for the placeable object
func _add_sync_properties(config: SceneReplicationConfig):
	super._add_sync_properties(config)
	config.add_property(NodePath(".:supply_count"))


## Initialize the supply
func _initialize_supply():
	if supply and supply.can_instantiate():
		supply_instance = supply.instantiate()
		return
	set_supply(supply_name)


# Set the supply script for the food crate
func set_supply(food_name: String):
	var scene_path = food_directory + food_name + ".tscn"
	supply = load(scene_path)
	if supply and supply.can_instantiate():
		supply_instance = supply.instantiate()
		print("FoodCrate supply set to: ", scene_path.get_file().get_basename())
	else:
		push_error("Failed to load or cannot instantiate scene: " + scene_path)


## Provide food from the crate
## @return: The food item that was taken, or null if not in IDLE status
func take() -> Node:
	if current_status != Status.IDLE:
		push_error("FoodCrate is not in IDLE status, cannot take food")
		return null
	current_status = Status.USING
	action_timer.start()

	var food = supply.instantiate()
	food.name = prefix + supply_name + str(supply_count)
	supply_count += 1
	ApplianceManager.register_item(food, current_owner, food.name)
	return food


## For Player interaction --------------------------------------------------------------------------

## Perform action depend on what player is holding
## @param _item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(item: Node) -> bool: # we may need player or id as parameter for multiplier!!!!!!!!!!!!!!!!!!
	if not item:
		var food = take()
		if not food:
			return false
		GlobalScript.player.pickup_item(food)
		# #----------------------------------------------------------------------
		# print("Player took food from FoodCrate: ", food.get_script().get_global_name())
		# print("Player has: ", GlobalScript.player.item_in_hand.get_script().get_global_name())
		# #----------------------------------------------------------------------
		return true
	if item is Cookware and item._can_accept(supply_instance):
		var food = take()
		if not food:
			return false
		item.put(food)
		return true
	return false


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
	if item is Cookware:
		if item._can_accept(supply_instance):
			highlight_component.show_feedback(true)
		else:
			highlight_component.show_feedback(false)
#---------------------------------------------------------------------------------------------------


## Override unsupported methods to prevent misuse ------------------------------
func put(_item: Node) -> bool:
	assert(false, "Food Crate does not support putting items")
	return false

func take_at(_index: int) -> Node:
	assert(false, "Food Crate does not support taking items at specific index")
	return null

func start_action() -> bool:
	assert(false, "Food Crate does not support starting actions")
	return false

func put_from_player(_item: Node) -> bool:
	assert(false, "Food Crate does not support putting items")
	return false
#-------------------------------------------------------------------------------
