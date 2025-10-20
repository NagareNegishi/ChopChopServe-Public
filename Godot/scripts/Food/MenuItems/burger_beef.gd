extends MenuItem
class_name burger_beef

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(burger_beef)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, burger_beef.new())

func _init():
	ingredients = ["Dough", "Cheese", "Tomato","Beef"]
	
	ingredient_states = {
		"Dough": ["RAW", "BAKED"],
		"Cheese": ["RAW","CHOPPED"],
		"Tomato": ["RAW","CHOPPED"],
		"Beef":["RAW", "FRIED"]
	}
	
	name_of_meal = "burger_beef"
	ui_texture = load("res://assets/textures/recipes/BeefBurger.png")
	ui_meal_name = "Beef Burger"
	ui_states = {
		"Dough": ["NONE", "BAKED"],
		"Cheese": ["CHOPPED", "NONE"],
		"Tomato":["CHOPPED","NONE"],
		"Beef":["NONE","FRIED"]
	}
func _ready():
	cooked_mesh_good = $BurgerBeef
	cooked_mesh_bad = $BadQualityBeefBurger
	cooked_mesh_burnt = $BurntBeefBurger
