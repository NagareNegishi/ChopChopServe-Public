extends MenuItem
class_name GarlicBread

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(GarlicBread)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.starters, GarlicBread.new())

func _ready():
	ingredients = ["Dough", "Garlic"]
	
	ingredient_states = {
		"Dough": ["RAW","ROLLED", "BAKED"],
		"Garlic": ["RAW","BLENDED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
