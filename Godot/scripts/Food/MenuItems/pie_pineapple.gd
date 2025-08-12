extends MenuItem
class_name PineapplePie

# Need to set ingredient list
# Need to make sure that the state of ingredients matches the state of the ingredient in the array

func _ready():
	ingredients = ["Dough","Pineapple"]
	
	ingredient_states = {
		"Pineapple": ["RAW","CHOPPED", "BAKED"],
		"Dough": ["RAW","ROLLED", "BAKED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
