extends MenuItem
class_name pizza_cheese

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(pizza_cheese)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, pizza_cheese.new())

func _init():
	ingredients = ["Dough", "Cheese", "Tomato"]
	diffuculty = 3
	cost = 280
	ingredient_states = {
		"Dough": ["RAW", "BAKED"],
		"Cheese": ["RAW","CHOPPED","BAKED"],
		"Tomato": ["RAW","MIXED","BAKED"]
	}
	ui_meal_name = "Cheese Pizza"
	ui_states = {
		"Dough":["NONE", "BAKED"],
		"Cheese":["CHOPPED","BAKED"],
		"Tomato":["MIXED","BAKED"],
	}

	name_of_meal = "pizza_cheese"
	ui_texture = load("res://assets/textures/recipes/CheesePizza.png")
	
func _ready():
	cooked_mesh_good = $PizzaCheese
	cooked_mesh_bad = $BadQualityCheesePizza
	cooked_mesh_burnt = $BurntCheesePizza
