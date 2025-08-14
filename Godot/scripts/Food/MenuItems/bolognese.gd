extends MenuItem
class_name Bolognese

# Need to set ingredient list
# Need to make sure that the state of ingredients matches the state of the ingredient in the array
static var _auto_register = MenuItem.register(Bolognese)
func _ready():
	ingredients = ["Beef", "Pasta", "Tomato"]
	
	ingredient_states = {
		"Beef": ["RAW","COOKED"],
		"Pasta": ["RAW","BOILED"],
		"Tomato":["RAW","BLENDED","COOKED"]
	}
	appliance = "Bowl"
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
	
