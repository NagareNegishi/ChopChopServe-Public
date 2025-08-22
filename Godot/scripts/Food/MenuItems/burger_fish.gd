extends MenuItem
class_name FishBurger

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(FishBurger)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, FishBurger)

func _ready():
	ingredients = ["Dough", "Cheese", "Tomato","Fish"]
	
	ingredient_states = {
		"Dough": ["RAW","ROLLED", "BAKED"],
		"Cheese": ["RAW","CHOPPED"],
		"Tomato": ["RAW","CHOPPED"],
		"Fish":["RAW","COOKED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
