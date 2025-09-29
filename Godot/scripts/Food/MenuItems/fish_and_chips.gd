extends MenuItem
class_name fish_and_chips

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(fish_and_chips)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, fish_and_chips.new())

func _init():
	ingredients = ["Fish", "Potato"]
	
	ingredient_states = {
		"Fish": ["RAW","FRIED"],
		"Potato": ["RAW","CHOPPED","FRIED"]
	}
	is_available = true

func _ready():
	cooked_mesh_good = $FishAndChips
	cooked_mesh_bad = $BadQualityFishNChips
	cooked_mesh_burnt = $BurntFishNChips
	name_of_meal = "fish_and_chips"
	ui_texture = load("res://assets/textures/recipes/FishnChips.png")
