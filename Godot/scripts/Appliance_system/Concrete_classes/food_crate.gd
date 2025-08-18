## Food Crate only provides a one type of ingredient, but takes nothing back.
## player can take food from food crate manually,
##
## Note: the implementation can be simplify by extending Appliance directly,
## however, considering the future extension, I will extend UnPoweredAppliance
class_name FoodCrate
extends UnPoweredAppliance

var supply: PackedScene
var food_directory: String = "res://scripts/Food/IngredientScenes/"

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/NuFurniture/FoodCrater.glb")

func _ready():
	super._ready()
	action_interval = 0.1 # small interval to avoid rapid item taking
	
	
	#------------------------------------
	set_supply("Tomato")
	#------------------------------------


# Set the supply script for the food crate
func set_supply(food_name: String):
	var scene_path = food_directory + food_name + ".tscn"
	supply = load(scene_path)
	if supply and supply.can_instantiate():
		print("FoodCrate supply set to: ", scene_path.get_file().get_basename())
	else:
		push_error("Failed to load or cannot instantiate scene: " + scene_path)


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
#-------------------------------------------------------------------------------


## Provide food from the crate
## @return: The food item that was taken, or null if not in IDLE status
func take() -> Node:
	if current_status != Status.IDLE:
		push_error("FoodCrate is not in IDLE status, cannot take food")
		return null
	current_status = Status.USING
	status_changed.emit(current_status)
	action_timer.start()
	return supply.instantiate()


## Perform action depend on what player is holding
## @param _item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(item: Node) -> bool: # we may need player or id as parameter for multiplier!!!!!!!!!!!!!!!!!!
	if not item:
		var food = take()
		GlobalScript.player.pickup_item(food)
		#----------------------------------------------------------------------
		print("Player took food from FoodCrate: ", food.get_script().get_global_name())
		print("Player has: ", GlobalScript.player.item_in_hand.get_script().get_global_name())
		#----------------------------------------------------------------------
		return true
	return false
