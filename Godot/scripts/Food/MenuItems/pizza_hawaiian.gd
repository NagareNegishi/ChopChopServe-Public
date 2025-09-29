extends MenuItem
class_name pizza_hawaiian

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(pizza_hawaiian)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, pizza_hawaiian.new())

func _init():
	ingredients = ["Dough", "Cheese", "Tomato", "Ham", "Pineapple"]
	
	ingredient_states = {
		"Dough": ["RAW", "BAKED"],
		"Cheese": ["RAW","CHOPPED","BAKED"],
		"Tomato": ["RAW","BLENDED","BAKED"],
		"Ham": ["RAW", "CHOPPED","BAKED"],
		"Pineapple":["RAW", "CHOPPED","BAKED"]
	}
	
	is_available=true

func _ready():
	cooked_mesh_good = $PizzaHawaii
	cooked_mesh_bad = $BadQualityHawaiPizza
	cooked_mesh_burnt = $BurntHawaiPizza
	name_of_meal = "pizza_hawaiian"
	ui_texture = load("res://assets/textures/recipes/HawaiianPizza.png")
