extends MenuItem
class_name OnionSoup

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(OnionSoup)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.starters,  OnionSoup.new())

func _init():
	ingredients = ["Onion", "Onion", "Onion", "Water"]
	
	ingredient_states = {
		"Onion": ["RAW","CHOPPED", "BOILED"],
		"Water": ["RAW","BOILED"]
	}
	
	is_available=true


func _ready():
	cooked_mesh_good = $SoupOnion
	cooked_mesh_bad = $BadQualityOnionSoup
	cooked_mesh_burnt = $BurntSoup
