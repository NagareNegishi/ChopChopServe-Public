class_name Freezer
extends PoweredAppliance

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/furniture/Fridge.glb")


## Setup the freezer properties
func _ready():
	super._ready()
	cooking_style = ApplianceFactory.CookingStyle.FREEZE
	valid_classes = ["Pot"] # Only one Pot allowed
	capacity = 1
	power = 1
	add_cookware("pot")

	# Maybe??
	# valid_classes = [load("res://scripts/Appliance_system/Concrete_classes/cookware.gd")]
	# cook_interval = 1.0