extends MenuItem
class_name OnionRings

# Need to set ingredient list
# Need to make sure that the state of ingredients matches the state of the ingredient in the array

func _ready():
	ingredients = ["Onion", "Onion"]
	
	ingredient_states = {
		"Onion": ["RAW","CHOPPED", "FRIED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
