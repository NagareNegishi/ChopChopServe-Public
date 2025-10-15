extends MenuItem
class_name onion_rings

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(onion_rings)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.starters, onion_rings.new())

func _init():
	ingredients = ["Onion", "Onion"]
	
	ingredient_states = {
		"Onion": ["RAW","CHOPPED", "FRIED"]
	}
	name_of_meal = "onion_rings"
	ui_texture = load("res://assets/textures/recipes/OnionRings.png")
	
func _ready():
	cooked_mesh_good = $OnionRings
	cooked_mesh_bad = $BadQualityOnionRings
	cooked_mesh_burnt = $BurntOnionRings
