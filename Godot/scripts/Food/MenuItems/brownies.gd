extends MenuItem
class_name Brownies

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(Brownies)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.deserts, Brownies.new())

func _ready():
	ingredients = ["Flour", "Cocoa", "Milk"]
	
	ingredient_states = {
		"Flour": ["RAW","MIXED"],
		"Cocoa": ["RAW","MIXED"],
		"Milk": ["RAW", "MIXED"]
	}
	
	cooked_mesh_good = $Brownie
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
