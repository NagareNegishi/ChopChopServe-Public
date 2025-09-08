class_name FryerBasket
extends Cookware

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/items/fryerbasket.glb")


## Setup the fryer properties
func _ready():
	super._ready()
	cooking_style = ApplianceFactory.CookingStyle.DEEP_FRY
	valid_food = ["Fish", "Tomato", "Potato", "Onion"] # Confirm later!!!!!!!!!!!!!!
	capacity = 4
	coefficient = 1.0
	
	add_to_group("Appliance")


## Override upgradable setup in concrete appliances
func _setup_upgradable():
	super._setup_upgradable()
	enable_upgrade("coefficient", [0.2, 0.2, 0.2], [100, 200, 300])
	enable_upgrade("capacity", [1, 1, 1], [80, 160, 240])
