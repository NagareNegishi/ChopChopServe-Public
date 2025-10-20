extends MenuItem
class_name taco_chicken

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(taco_chicken)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, taco_chicken.new())

func _init():
	ingredients = ["Dough", "Chicken", "Tomato"]
	
	ingredient_states = {
		"Chicken": ["RAW","FRIED"],
		"Dough": ["RAW", "BAKED"],
		"Tomato":["RAW","CHOPPED"]
	}
	
	name_of_meal = "taco_chicken"
	ui_texture = load("res://assets/textures/recipes/ChickenTaco.png")
	ui_meal_name = "Chicken Taco"
	ui_states = {
		"Beef":["NONE", "FRIED"],
		"Dough":["NONE","BAKED"],
		"Tomato":["CHOPPED","NONE"]
	}
func _ready():
	cooked_mesh_good = $TacoChicken
	cooked_mesh_bad = $BadQualityChickentaco
	cooked_mesh_burnt = $BurntChickenTaco
