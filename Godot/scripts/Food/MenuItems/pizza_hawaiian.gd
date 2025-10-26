extends MenuItem
class_name pizza_hawaiian

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(pizza_hawaiian)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, pizza_hawaiian.new())

func _init():
	ingredients = ["Dough", "Cheese", "Tomato", "Pineapple"]
	
	ingredient_states = {
		"Dough": ["RAW", "BAKED"],
		"Cheese": ["RAW","CHOPPED","BAKED"],
		"Tomato": ["RAW","MIXED","BAKED"],
		"Pineapple":["RAW", "CHOPPED","BAKED"]
	}
	ui_meal_name = "Hawaiian Pizza"
	ui_states = {
		"Dough":["NONE", "BAKED"],
		"Cheese":["CHOPPED","BAKED"],
		"Tomato":["MIXED","BAKED"],
		"Pineapple":["CHOPPED","BAKED"],
	}
	name_of_meal = "pizza_hawaiian"
	ui_texture = load("res://assets/textures/recipes/HawaiianPizza.png")
	
func _ready():
	cooked_mesh_good = $PizzaHawaii
	cooked_mesh_bad = $BadQualityHawaiPizza
	cooked_mesh_burnt = $BurntHawaiPizza
