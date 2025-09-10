extends MenuItem
class_name ChickenTaco

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(ChickenTaco)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, ChickenTaco.new())

func _ready():
	ingredients = ["Dough", "Chicken", "Tomato"]
	
	ingredient_states = {
		"Chicken": ["RAW","COOKED"],
		"Dough": ["RAW","ROLLED", "COOKED"],
		"Tomato":["RAW","CHOPPED"]
	}
	
	is_available=true


func _init():
	cooked_mesh_good = $TacoChicken
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
