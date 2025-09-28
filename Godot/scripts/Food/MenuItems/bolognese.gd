extends MenuItem
class_name Bolognese

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(Bolognese)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, Bolognese.new())

func _init():
	ingredients = ["Beef", "Pasta", "Tomato"]
	
	ingredient_states = {
		"Beef": ["RAW","FRIED"],
		"Pasta": ["RAW","BOILED"],
		"Tomato":["RAW","MIXED","FRIED"]
	}
	#appliance = "Bowl"
	is_available=true

func _ready():
	cooked_mesh_good = $SpagBol
	cooked_mesh_bad = $BadQualitySpagBol
	cooked_mesh_burnt = $BurntSpagBol
	ui_texture = load("res://assets/textures/recipes/Bolognse.png")
