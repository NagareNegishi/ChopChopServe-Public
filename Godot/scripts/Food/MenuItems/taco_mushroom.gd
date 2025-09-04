extends MenuItem
class_name MushroomTaco

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(MushroomTaco)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, MushroomTaco.new())


func _ready():
	ingredients = ["Dough", "Mushroom", "Tomato"]
	
	ingredient_states = {
		"Mushroom": ["RAW","CHOPPED","COOKED"],
		"Dough": ["RAW","ROLLED", "COOKED"],
		"Tomato":["RAW","CHOPPED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
