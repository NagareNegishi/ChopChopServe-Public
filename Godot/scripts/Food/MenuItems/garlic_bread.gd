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
		"Dough": ["RAW", "BAKED"],
		"Garlic": ["RAW","CHOPPED", "BAKED"]
	}
	
	is_available = true

func _inti():
	cooked_mesh_good = $BreadGarlic
	cooked_mesh_bad = $BadQualityGarlicBread
	cooked_mesh_burnt = $BurntGarlicBread
