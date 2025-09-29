extends MenuItem
class_name icecream_vani

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(icecream_vani)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.deserts, icecream_vani.new())

func _init():
	ingredients = ["Vanilla Icecream"]
	
	ingredient_states = {
		"Vanilla Icecream": ["RAW","BLENDED"]
	}
	
	is_available=true

func _ready():
	cooked_mesh_good = $IceCreamVanilla
	cooked_mesh_bad = $IceCreamVanilla2
	cooked_mesh_burnt = null
	name_of_meal = "icecream_vani"
	ui_texture = load("res://assets/textures/recipes/Vanillaicecream.png")
