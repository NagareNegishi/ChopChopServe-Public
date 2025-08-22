extends MenuItem
class_name OnionRings

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(OnionRings)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.starters, OnionRings)

func _ready():
	ingredients = ["Onion", "Onion"]
	
	ingredient_states = {
		"Onion": ["RAW","CHOPPED", "FRIED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
