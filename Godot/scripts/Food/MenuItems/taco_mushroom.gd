extends MenuItem
class_name MushrooomTaco

# Need to set ingredient list
# Need to make sure that the state of ingredients matches the state of the ingredient in the array

func _ready():
	ingredients = ["Dough", "Mushroom", "Tomato"]
	
	ingredient_states = {
		"Mushroom": ["RAW","CHOPPED","COOKED"],
		"Dough": ["RAW","ROLLED", "COOKED"],
		"Tomato":["RAW","CHOPPED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
