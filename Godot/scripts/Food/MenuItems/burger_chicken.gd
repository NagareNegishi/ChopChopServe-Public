extends MenuItem
class_name burger_chicken

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(burger_chicken)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, burger_chicken.new())

func _init():
	ingredients = ["Dough", "Cheese", "Tomato","Chicken"]
	
	ingredient_states = {
		"Dough": ["RAW", "BAKED"],
		"Cheese": ["RAW","CHOPPED"],
		"Tomato": ["RAW","CHOPPED"],
		"Chicken":["RAW","FRIED"]
	}
	
	name_of_meal = "burger_chicken"
	ui_texture = load("res://assets/textures/recipes/ChickenBurger.png")
	ui_meal_name = "Chicken Burger"
	ui_states = {
		"Dough": ["NONE", "BAKED"],
		"Cheese": ["CHOPPED", "NONE"],
		"Tomato":["CHOPPED","NONE"],
		"Chicken":["NONE","FIRED"]
	}

func _ready():
	cooked_mesh_good = $BurgerChicken
	cooked_mesh_bad = $BadQualityChickenBurger
	cooked_mesh_burnt = $BurntChickenBurger
