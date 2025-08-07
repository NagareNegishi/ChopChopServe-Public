class_name Stove
extends PoweredAppliance

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/furniture/Stove.glb")


## Setup the stove properties
func _ready():
	super._ready()
	cooking_style = ApplianceFactory.CookingStyle.HEAT
	# capacity = 4
	# power = 1

	# Maybe??
	# valid_classes = [load("res://scripts/Appliance_system/Concrete_classes/cookware.gd")]
	# cook_interval = 1.0
