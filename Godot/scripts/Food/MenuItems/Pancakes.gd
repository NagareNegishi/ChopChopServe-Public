extends MenuItem
class_name Pancakes

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(Pancakes)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.starters, Pancakes.new())

func _ready():
	ingredients = ["Flour", "Water", "Milk", "Egg"]
	
	ingredient_states = {
		"Flour":["RAW","MIXED","FRIED"],
		"Water":["RAW","MIXED","FRIED"],
		"Egg":["RAW","MIXED","FRIED"],
		"Milk":["RAW","MIXED","FRIED"]
	}
	
	is_available=true


func _init():
	cooked_mesh_good = $Pancakes
	cooked_mesh_bad = $BadQualityPancakes
	cooked_mesh_burnt = $BurntPancakes
	ui_texture = load("res://assets/textures/recipes/Pancakes.png")
