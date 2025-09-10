extends MenuItem
class_name OnionRings

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(OnionRings)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.starters, OnionRings.new())

func _init():
	ingredients = ["Onion", "Onion"]
	
	ingredient_states = {
		"Onion": ["RAW","CHOPPED", "FRIED"]
	}
	is_available = true

func _ready():
	cooked_mesh_good = $OnionRings
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
