extends MenuItem
class_name pizza_meat

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(pizza_meat)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, pizza_meat.new())

func _init():
	ingredients = ["Dough", "Cheese", "Tomato", "Beef"]
	
	ingredient_states = {
		"Dough": ["RAW", "BAKED"],
		"Cheese": ["RAW","BLENDED","BAKED"],
		"Tomato": ["RAW","CHOPPED","BAKED"],
		"Beef":["RAW", "FRIED", "BAKED"]
	}
	
	name_of_meal = "pizza_meat"
	ui_texture = load("res://assets/textures/recipes/PepperoniPizza.png")
	ui_meal_name = "Meat Pizza"
	ui_states = {
		"Dough":["NONE", "BAKED"],
		"Cheese":["CHOPPED","BAKED"],
		"Tomato":["MIXED","BAKED"],
		"Beef":["NONE","BAKED"],
	}

func _ready():
	cooked_mesh_good = $PizzaPep
	cooked_mesh_bad = $BadQualityPepPizza
	cooked_mesh_burnt = $BurntPepPizza
