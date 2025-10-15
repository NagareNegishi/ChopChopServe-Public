extends MenuItem
class_name pancakes

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(pancakes)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.starters, pancakes.new())

func _init():
	ingredients = ["Flour", "Milk"]
	
	ingredient_states = {
		"Flour":["RAW","MIXED","FRIED"],
		"Milk":["RAW","MIXED","FRIED"]
	}
	
	name_of_meal = "pancakes"
	ui_texture = load("res://assets/textures/recipes/Pancakes.png")


func _ready():
	cooked_mesh_good = $Pancakes
	cooked_mesh_bad = $BadQualityPancakes
	cooked_mesh_burnt = $BurntPancakes
