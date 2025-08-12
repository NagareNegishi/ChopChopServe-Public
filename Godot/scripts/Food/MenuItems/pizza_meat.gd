extends MenuItem
class_name MeatPizza

# Need to set ingredient list
# Need to make sure that the state of ingredients matches the state of the ingredient in the array

func _ready():
	ingredients = ["Dough", "Cheese", "Tomato", "Beef"]
	
	ingredient_states = {
		"Dough": ["RAW","ROLLED", "BAKED"],
		"Cheese": ["RAW","BLENDED","BAKED"],
		"Tomato": ["RAW","CHOPPED","BAKED"],
		"Beef":["RAW", "COOKED", "BAKED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
