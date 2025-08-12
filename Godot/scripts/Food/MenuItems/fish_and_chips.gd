extends MenuItem
class_name FishAndChips

# Need to set ingredient list
# Need to make sure that the state of ingredients matches the state of the ingredient in the array

func _ready():
	ingredients = ["Fish", "Potato"]
	
	ingredient_states = {
		"Fish": ["RAW","COOKED"],
		"Potato": ["RAW","CHOPPED","FRIED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
