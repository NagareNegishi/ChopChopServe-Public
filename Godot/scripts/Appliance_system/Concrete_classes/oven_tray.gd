class_name OvenTray
extends Cookware


## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/newmodels/items/OvenTray.glb")
	default_facing = Direction.WEST
	capacity = 4
	sound = SoundManager.SFX_COOKING.PAN_FRY # for now use pan fry sound


## Setup the fryer properties
func _ready():
	super._ready()
	cooking_style = ApplianceFactory.CookingStyle.BAKE
	valid_food = ["Fish", "Tomato", "Potato", "Flour", "Cocoa", "Milk", "Dough", "Cheese",
					"Apple", "Beef", "Garlic", "Ham", "Pasta", "Pineapple", "Pumpkin","Egg"]
	coefficient = 1.0
	
	add_to_group("Appliance")


## Place an item onto this OvenTray
## @param item: The Node to place on this OvenTray
func _put(item: Node) -> void:
	super._put(item)
	# if in oven, hide food
	if item is Food and power_receiving > 0:
		item.current_visibility(false)