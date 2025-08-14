extends MenuItem
class_name SteakAndChips

# Need to set ingredient list
# Need to make sure that the state of ingredients matches the state of the ingredient in the array

static var _auto_register = MenuItem.register(SteakAndChips)

func _ready():
	ingredients = ["Beef", "Potato"]
	
	ingredient_states = {
		"Beef": ["RAW","COOKED"],
		"Potato": ["RAW","CHOPPED","FRIED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
