extends MenuItem
class_name PumpkinPie

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(PumpkinPie)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.deserts, PumpkinPie.new())

func _init():
	ingredients = ["Dough","Pumpkin"]
	
	ingredient_states = {
		"Pumpkin": ["RAW","CHOPPED", "BAKED"],
		"Dough": ["RAW", "BAKED"]
	}
	
	is_available = true

func _ready():
	cooked_mesh_good = $PiePumpkin
	cooked_mesh_bad = $BadQualityPumpkinPie
	cooked_mesh_burnt = $BurntPumpkinPie
	ui_texture = load("res://assets/textures/recipes/PumpkinPie.png")
