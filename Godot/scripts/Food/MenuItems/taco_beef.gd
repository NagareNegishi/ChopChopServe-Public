extends MenuItem
class_name BeefTaco

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(BeefTaco)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, BeefTaco.new())

func _ready():
	ingredients = ["Dough", "Beef", "Tomato"]
	
	ingredient_states = {
		"Beef": ["RAW","FRIED"],
		"Dough": ["RAW", "BAKED"],
		"Tomato":["RAW","CHOPPED"]
	}
	
	is_available = true

func _init():
	cooked_mesh_good = $TacoBeef
	cooked_mesh_bad = $BadQualityBeefTaco
	cooked_mesh_burnt = $BurntBeefTaco
