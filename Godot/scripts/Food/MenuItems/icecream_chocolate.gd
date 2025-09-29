extends MenuItem
class_name icecream_chocolate

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(icecream_chocolate)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.deserts, icecream_chocolate.new())

func _init():
	ingredients = ["Vanilla Icecream", "Cocoa"]
	
	ingredient_states = {
		"Vanilla Icecream": ["RAW","BLENDED"],
		"Cocoa": ["RAW","BLENDED"]
	}
	
	is_available = true

func _ready():
	cooked_mesh_good = $IceCreamChoc
	cooked_mesh_bad = $IceCreamChoc2
	cooked_mesh_burnt = null
	name_of_meal = "icecream_chocolate"
	ui_texture = load("res://assets/textures/recipes/ChocolateIcecream.png")
