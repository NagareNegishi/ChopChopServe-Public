extends MenuItem
class_name pie_apple

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(pie_apple)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.deserts, pie_apple.new())

func _init():
	ingredients = ["Dough","Apple"]
	
	ingredient_states = {
		"Apple": ["RAW","CHOPPED", "BAKED"],
		"Dough": ["RAW", "BAKED"]
	}
	
	name_of_meal = "pie_apple"
	ui_texture = load("res://assets/textures/recipes/ApplePie.png")

func _ready():
	cooked_mesh_good = $ApplePie
	cooked_mesh_bad = $BadQualityApplePie
	cooked_mesh_burnt = $BurntApplePie
