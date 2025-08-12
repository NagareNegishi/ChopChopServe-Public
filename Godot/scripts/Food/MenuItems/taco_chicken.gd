extends MenuItem
class_name ChickenTaco

# Need to set ingredient list
# Need to make sure that the state of ingredients matches the state of the ingredient in the array

func _ready():
	ingredients = ["Dough", "Chicken", "Tomato"]
	
	ingredient_states = {
		"Chicken": ["RAW","COOKED"],
		"Dough": ["RAW","ROLLED", "COOKED"],
		"Tomato":["RAW","CHOPPED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
