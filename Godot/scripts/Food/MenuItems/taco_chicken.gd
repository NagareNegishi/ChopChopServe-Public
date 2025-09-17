extends MenuItem
class_name ChickenTaco

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(ChickenTaco)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, ChickenTaco.new())

func _init():
	ingredients = ["Dough", "Chicken", "Tomato"]
	
	ingredient_states = {
		"Chicken": ["RAW","FRIED"],
		"Dough": ["RAW", "BAKED"],
		"Tomato":["RAW","CHOPPED"]
	}
	
	is_available=true

func _ready():
	cooked_mesh_good = $TacoChicken
	cooked_mesh_bad = $BadQualityChickentaco
	cooked_mesh_burnt = $BurntChickenTaco
