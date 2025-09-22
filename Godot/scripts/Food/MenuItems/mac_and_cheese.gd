extends MenuItem
class_name MacAndCheese

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(MacAndCheese)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.starters, MacAndCheese.new())

func _init():
	ingredients = ["Pasta", "Cheese"]
	
	ingredient_states = {
		"Pasta": ["RAW","BOILED","BAKED"],
		"Cheese": ["RAW", "CHOPPED", "BAKED"]
	}
	
	is_available=true

func _ready():
	cooked_mesh_good = $MacnCheese
	cooked_mesh_bad = $BadQualityMacNCheese
	cooked_mesh_burnt = $BurntMacNCheese
