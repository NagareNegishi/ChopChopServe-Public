extends MenuItem
class_name PumpkinSoup

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(PumpkinSoup)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.starters, PumpkinSoup.new())

func _ready():
	ingredients = ["Pumpkin", "Water"]
	
	ingredient_states = {
		"Pumpkin": ["RAW","CHOPPED", "BOILED"],
		"Water": ["RAW","BOILED"]
	}
	
	# This is the appliance it is to be collected in 
	#appliance = "Bowl"
	is_available=true


func _init():
	cooked_mesh_good = $SoupPumpkin
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
