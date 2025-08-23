extends MenuItem
class_name Bolognese

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(Bolognese)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, Bolognese)

func _ready():
	ingredients = ["Beef", "Pasta", "Tomato"]
	
	ingredient_states = {
		"Beef": ["RAW","COOKED"],
		"Pasta": ["RAW","BOILED"],
		"Tomato":["RAW","BLENDED","COOKED"]
	}
	#appliance = "Bowl"
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
	
