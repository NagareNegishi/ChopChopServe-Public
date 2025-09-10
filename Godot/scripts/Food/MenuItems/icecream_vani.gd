extends MenuItem
class_name VaniIcecream

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(VaniIcecream)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.deserts, VaniIcecream.new())

func _init():
	ingredients = ["Vanilla Icecream"]
	
	ingredient_states = {
		"Vanilla Icecream": ["RAW","BLENDED"]
	}
	
	is_available=true

func _ready():
	cooked_mesh_good = $IceCreamVanilla
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
