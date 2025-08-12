extends MenuItem
class_name StrawberryIcecream

# Need to set ingredient list
# Need to make sure that the state of ingredients matches the state of the ingredient in the array

func _ready():
	ingredients = ["Vanilla Icecream", "Strawberry","Strawberry","Strawberry"]
	
	ingredient_states = {
		"Vanilla Icecream": ["RAW","BLENDED"],
		"Strawberry": ["RAW","CHOPPED","BLENDED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
