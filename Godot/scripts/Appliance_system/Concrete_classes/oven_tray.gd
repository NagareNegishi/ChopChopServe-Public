class_name OvenTray
extends Cookware

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/items/Johno'sOverTray.glb") # for test


## Setup the fryer properties
func _ready():
	super._ready()
	cooking_style = ApplianceFactory.CookingStyle.BAKE
	valid_food = ["Fish", "Tomato", "Potato", "Flour", "Cocoa", "Milk", "Dough", "Cheese",
					"Apple", "Beef", "Garlic", "Ham", "Pasta", "Pineapple", "Pumpkin","Egg"]
	capacity = 4
	coefficient = 1.0
	
	add_to_group("Appliance")
