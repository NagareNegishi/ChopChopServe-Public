class_name FryerBasket
extends Cookware

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/furniture/StoveMulti.glb") # for test


## Setup the fryer properties
func _ready():
	super._ready()
	cooking_style = ApplianceFactory.CookingStyle.DEEP_FRY
	valid_food_names = ["Fish"] # Confirm later!!!!!!!!!!!!!!
	capacity = 4
	coefficient = 1.0
