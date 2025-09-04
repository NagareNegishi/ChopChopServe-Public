extends MenuItem
class_name FishAndChips

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(FishAndChips)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, FishAndChips.new())

func _init():
	ingredients = ["Fish", "Potato"]
	
	ingredient_states = {
		"Fish": ["RAW","FRIED"],
		"Potato": ["RAW","CHOPPED","FRIED"]
	}
	is_available = true

func _ready():
	cooked_mesh_good = $FishAndChips
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
