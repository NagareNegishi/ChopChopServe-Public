extends MenuItem
class_name HawaiianPizza

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(HawaiianPizza)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, HawaiianPizza.new())

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
	ui_texture = load("res://assets/textures/recipes/HawaiianPizza.png")
