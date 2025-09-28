extends MenuItem
class_name BeefBurger

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(BeefBurger)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, BeefBurger.new())

func _ready():
	ingredients = ["Dough", "Cheese", "Tomato","Beef"]
	
	ingredient_states = {
		"Dough": ["RAW", "BAKED"],
		"Cheese": ["RAW","CHOPPED"],
		"Tomato": ["RAW","CHOPPED"],
		"Beef":["RAW", "FRIED"]
	}
	
	is_available = true

func _int():
	cooked_mesh_good = $BurgerBeef
	cooked_mesh_bad = $BadQualityBeefBurger
	cooked_mesh_burnt = $BurntBeefBurger
	ui_texture = load("res://assets/textures/recipes/BeefBurger.png")
