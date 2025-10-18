class_name Pot
extends Cookware

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/newmodels/items/POTNEW.glb") # for test
	capacity = 4

## Setup the fryer properties
func _ready():
	super._ready()
	cooking_style = ApplianceFactory.CookingStyle.BOIL
	valid_food = ["Fish", "Tomato", "Water", "Mushroom", "Onion", "Pasta", "Pumpkin"]
	coefficient = 1.0
	
	add_to_group("Appliance")
