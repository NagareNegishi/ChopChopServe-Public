class_name FryingPan
extends Cookware

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/items/Pan.glb")

## Setup the fryer properties
func _ready():
	super._ready()
	cooking_style = ApplianceFactory.CookingStyle.PAN_FRY
	valid_food = ["Fish", "Tomato", "Beef", "Chicken", "Fish", "Milk", "Water", "Mushroom"] # Confirm later!!!!!!!!!!!!!!
	capacity = 4
	coefficient = 1.0
	add_to_group("Appliance")
