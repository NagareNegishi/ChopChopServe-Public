extends MenuItem
class_name CheeseBread

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(CheeseBread)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.starters, CheeseBread.new())

func _init():
	ingredients = ["Dough", "Cheese"]
	
	ingredient_states = {
		"Dough": ["RAW", "BAKED"],
		"Cheese": ["RAW","CHOPPED","BAKED"]
	}
	
	is_available = true

func _ready():
	cooked_mesh_good = $BreadCheesy
	cooked_mesh_bad = $BadQualityCheeseBread
	cooked_mesh_burnt = $BurntCheeseBread
	ui_texture = load("res://assets/textures/recipes/CheeseBread.png")
