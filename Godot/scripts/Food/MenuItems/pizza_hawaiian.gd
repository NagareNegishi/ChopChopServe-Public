extends MenuItem
class_name HawaiianPizza

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(HawaiianPizza)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, HawaiianPizza)

func _ready():
	ingredients = ["Dough", "Cheese", "Tomato", "Ham", "Pineapple"]
	
	ingredient_states = {
		"Dough": ["RAW","ROLLED", "BAKED"],
		"Cheese": ["RAW","BLENDED","BAKED"],
		"Tomato": ["RAW","CHOPPED","BAKED"],
		"Ham": ["RAW", "CHOPPED","BAKED"],
		"Pineapple":["RAW", "CHOPPED","BAKED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
