extends MenuItem
class_name taco_beef

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(taco_beef)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, taco_beef.new())

func _init():
	ingredients = ["Dough", "Beef", "Tomato"]
	
	ingredient_states = {
		"Beef": ["RAW","FRIED"],
		"Dough": ["RAW", "BAKED"],
		"Tomato":["RAW","CHOPPED"]
	}
	
	is_available = true
	name_of_meal = "taco_beef"
	ui_texture = load("res://assets/textures/recipes/BeefTaco.png")
	
func _ready():
	cooked_mesh_good = $TacoBeef
	cooked_mesh_bad = $BadQualityBeefTaco
	cooked_mesh_burnt = $BurntBeefTaco
