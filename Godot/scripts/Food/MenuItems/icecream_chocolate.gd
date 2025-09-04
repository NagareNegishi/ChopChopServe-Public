extends MenuItem
class_name ChocolateIcecream

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(ChocolateIcecream)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.deserts, ChocolateIcecream.new())

func _ready():
	ingredients = ["Vanilla Icecream", "Cocoa"]
	
	ingredient_states = {
		"Vanilla Icecream": ["RAW","BLENDED"],
		"Cocoa": ["RAW","BLENDED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
