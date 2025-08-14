extends MenuItem
class_name OnionSoup

# Need to set ingredient list
# Need to make sure that the state of ingredients matches the state of the ingredient in the array
static var _auto_register = MenuItem.register(OnionSoup)
func _ready():
	ingredients = ["Onion", "Onion", "Onion", "Water"]
	
	ingredient_states = {
		"Onion": ["RAW","CHOPPED", "BOILED"],
		"Water": ["RAW","BOILED"]
	}
	
	# This is the appliance it is to be collected in 
	appliance = "Bowl"
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
	
	register(self)
