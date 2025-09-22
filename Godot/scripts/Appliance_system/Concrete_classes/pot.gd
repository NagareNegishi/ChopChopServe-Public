class_name Pot
extends Cookware

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/items/Johno'sPot.glb") # for test


## Setup the fryer properties
func _ready():
	super._ready()
	cooking_style = ApplianceFactory.CookingStyle.BOIL
	valid_food = ["Fish", "Tomato", "Water", "Mushroom", "Onion", "Pasta", "Pumpkin"] # Confirm later!!!!!!!!!!!!!!
	capacity = 4
	coefficient = 1.0


## Override upgradable setup in concrete appliances
func _setup_upgradable():
	super._setup_upgradable()
	enable_upgrade("coefficient", [0.2, 0.2, 0.2], [100, 200, 300])
	enable_upgrade("capacity", [1, 1, 1], [80, 160, 240])
