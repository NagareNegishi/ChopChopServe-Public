extends MenuItem
class_name ApplePie

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(ApplePie)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.deserts, ApplePie.new())

func _init():
	ingredients = ["Dough","Apple"]
	
	ingredient_states = {
		"Apple": ["RAW","CHOPPED", "BAKED"],
		"Dough": ["RAW", "BAKED"]
	}
	
	is_available = true

func _ready():
	cooked_mesh_good = $ApplePie
	cooked_mesh_bad = $BadQualityApplePie
	cooked_mesh_burnt = $BurntApplePie
