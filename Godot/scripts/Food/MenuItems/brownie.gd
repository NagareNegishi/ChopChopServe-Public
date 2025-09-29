extends MenuItem
class_name brownie

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(brownie)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.deserts, brownie.new())

func _init():
	ingredients = ["Flour", "Cocoa", "Milk", "Egg"]
	
	ingredient_states = {
		"Flour": ["RAW","MIXED","BAKED"],
		"Cocoa": ["RAW","MIXED","BAKED"],
		"Egg": ["RAW","MIXED","BAKED"],
		"Milk": ["RAW", "MIXED","BAKED"]
	}
	is_available = true

func _ready():
	cooked_mesh_good = $Brownie
	cooked_mesh_bad = $BadQualityBrownie
	cooked_mesh_burnt = $BurntBrownie
	name_of_meal = "brownie"
	ui_texture = load("res://assets/textures/recipes/Brownie.png")
