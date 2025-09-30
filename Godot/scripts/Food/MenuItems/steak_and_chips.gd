extends MenuItem
class_name steak_and_chips

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(steak_and_chips)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, steak_and_chips.new())

func _init():
	ingredients = ["Beef", "Potato"]
	
	ingredient_states = {
		"Beef": ["RAW","FRIED"],
		"Potato": ["RAW","CHOPPED","FRIED"]
	}
	
	is_available=true
	name_of_meal = "steak_and_chips"
	ui_texture = load("res://assets/textures/recipes/SteakNChips.png")

func _ready():
	cooked_mesh_good = $SteakChips
	cooked_mesh_bad = $BadQualitySteakChips
	cooked_mesh_burnt = $BurntSteakChips
