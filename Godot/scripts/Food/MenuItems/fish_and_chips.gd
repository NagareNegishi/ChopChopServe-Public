extends MenuItem
class_name FishAndChips

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(FishAndChips)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, FishAndChips.new())

func _ready():
	ingredients = ["Fish", "Potato"]
	
	ingredient_states = {
		"Fish": ["RAW","COOKED"],
		"Potato": ["RAW","CHOPPED","FRIED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
