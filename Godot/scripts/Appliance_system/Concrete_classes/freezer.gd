class_name Freezer
extends PoweredAppliance

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/furniture/Fridge.glb")


## Setup the freezer properties
func _ready():
	super._ready()
	# cooking_style = ApplianceFactory.CookingStyle.FREEZE
	valid_classes = ["Pot"] # Only one Pot allowed
	capacity = 1
	power = 1
	_add_cookware("pot")

	# Maybe??
	# cook_interval = 1.0


## Override upgradable setup in concrete appliances
func _setup_upgradable():
	super._setup_upgradable()
	enable_upgrade("power", [1, 1, 1], [100, 200, 300])
	enable_upgrade("capacity", [1, 1, 1], [80, 160, 240])
