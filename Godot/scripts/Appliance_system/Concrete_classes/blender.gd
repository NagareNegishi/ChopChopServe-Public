class_name Blender
extends PoweredAppliance

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/furniture/Blender.glb")


## Setup the blender properties
func _ready():
	super._ready()
	cooking_style = ApplianceFactory.CookingStyle.BLEND
	# capacity = 4
	# power = 1

	# Maybe??
	# valid_classes = [load("res://scripts/Appliance_system/Concrete_classes/cookware.gd")]
	# cook_interval = 1.0


## Override upgradable setup in concrete appliances
func _setup_upgradable():
	super._setup_upgradable()
	enable_upgrade("power", [1, 1, 1], [100, 200, 300])
	enable_upgrade("capacity", [1, 1, 1], [80, 160, 240])