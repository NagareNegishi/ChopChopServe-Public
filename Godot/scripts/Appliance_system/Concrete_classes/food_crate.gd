## Food Crate only provides a one type of ingredient, but takes nothing back.
## player can take food from food crate manually,
##
## Note: the implementation can be simplify by extending Appliance directly,
## however, considering the future extension, I will extend UnPoweredAppliance
class_name FoodCrate
extends UnPoweredAppliance

var supply: Script ## Must be Food class


## Setup the model instance
func _init():
	super._init()

	# until model is ready !!!!!!!!!!!!!
	model_scene = preload("res://assets/models/furniture/BasicBenchFatDrawers.glb")


func _ready():
	super._ready()
	# valid_classes = [Food]
	# capacity = 1000000 ## no limit on food crate
	# action_interval = 0.1 ## maybe small amount to avoid rapidly taking items?

	#set_supply()


## Set the supply script for the food crate
func set_supply():
	if valid_classes.is_empty():
		assert(false, "FoodCrate must have at least one valid class in valid_classes array")

	for script in valid_classes:
		if script != null: # is not get compile error
			var instance = script.new()
			# if instance is Food:
			if instance.has_method("is_food"):
				supply = script
				instance.queue_free()
				print("FoodCrate supply set to: ", supply)
				return
			instance.queue_free()
	assert(false, "FoodCrate must have at least one valid class in valid_classes array")


## Override unsupported methods to prevent misuse
func put(_item: Node) -> bool:
	assert(false, "Food Crate does not support putting items")
	return false

func take_at(_index: int) -> Node:
	assert(false, "Food Crate does not support taking items at specific index")
	return null

func start_action() -> bool:
	assert(false, "Food Crate does not support starting actions")
	return false


## Provide food from the crate
## @return: The food item that was taken, or null if not in IDLE status
func take() -> Node:
	if current_status != Status.IDLE:
		push_error("FoodCrate is not in IDLE status, cannot take food")
		return null
	current_status = Status.USING
	status_changed.emit(current_status)
	action_timer.start()
	return supply.new()
