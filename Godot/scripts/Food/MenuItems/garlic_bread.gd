extends MenuItem
class_name garlic_bread

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(garlic_bread)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.starters, garlic_bread.new())

func _init():
	ingredients = ["Dough", "Garlic"]
	
	ingredient_states = {
		"Dough": ["RAW", "BAKED"],
		"Garlic": ["RAW","CHOPPED", "BAKED"]
	}
	
	name_of_meal = "garlic_bread"
	ui_texture = load("res://assets/textures/recipes/GarlicBread.png")
	ui_meal_name = "Garlic Bread"
	ui_states = {
		"Dough":["NONE", "BAKED"],
		"Garlic":["CHOPPED","BAKED"]
	}

func _ready():
	cooked_mesh_good = $BreadGarlic
	cooked_mesh_bad = $BadQualityGarlicBread
	cooked_mesh_burnt = $BurntGarlicBread
