extends MenuItem
class_name SteakAndChips

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(SteakAndChips)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, SteakAndChips)

func _ready():
	ingredients = ["Beef", "Potato"]
	
	ingredient_states = {
		"Beef": ["RAW","COOKED"],
		"Potato": ["RAW","CHOPPED","FRIED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
