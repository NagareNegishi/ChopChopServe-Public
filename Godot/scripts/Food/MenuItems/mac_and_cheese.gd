extends MenuItem
class_name mac_and_cheese

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(mac_and_cheese)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.starters, mac_and_cheese.new())

func _init():
	ingredients = ["Pasta", "Cheese"]
	
	ingredient_states = {
		"Pasta": ["RAW","BOILED","BAKED"],
		"Cheese": ["RAW", "CHOPPED", "BAKED"]
	}
	
	name_of_meal = "mac_and_cheese"
	ui_texture = load("res://assets/textures/recipes/MacNCheese.png")
	ui_meal_name = "DO NOT USE"
	ui_states = {
		"Pasta":["BOIDED, BAKED"],
		"Garlic":["CHOPPED","BAKED"]
	}
	
func _ready():
	cooked_mesh_good = $MacnCheese
	cooked_mesh_bad = $BadQualityMacNCheese
	cooked_mesh_burnt = $BurntMacNCheese
