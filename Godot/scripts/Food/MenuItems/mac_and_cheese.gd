extends MenuItem
class_name MacAndCheese

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(MacAndCheese)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.starters, MacAndCheese.new())

func _ready():
	ingredients = ["Pasta", "Cheese"]
	
	ingredient_states = {
		"Pasta": ["RAW","BOILED","BAKED"],
		"Cheese": ["RAW", "BLENDED", "BAKED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
