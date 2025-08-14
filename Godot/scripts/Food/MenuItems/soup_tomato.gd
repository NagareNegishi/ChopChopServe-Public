extends MenuItem
class_name TomatoSoup

# Need to set ingredient list
# Need to make sure that the state of ingredients matches the state of the ingredient in the array
static var _auto_register = MenuItem.register(TomatoSoup)

func _init():
	ingredients = ["Tomato","Tomato","Tomato", "Water"]
	
	ingredient_states = {
		"Tomato": ["RAW","CHOPPED", "BOILED"],
		"Water": ["RAW","BOILED"]
	}
	
	# This is the appliance it is to be collected in 
	appliance = "Bowl"

func _ready():
	cooked_mesh_good = $tomatosoup_good
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
	
