class_name Pot
extends Cookware

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/furniture/StoveMulti.glb") # for test


## Setup the fryer properties
func _ready():
	super._ready()
	cooking_style = ApplianceFactory.CookingStyle.BOIL
	valid_food = ["Fish", "Tomato", "Water"] # Confirm later!!!!!!!!!!!!!!
	capacity = 4
	coefficient = 1.0