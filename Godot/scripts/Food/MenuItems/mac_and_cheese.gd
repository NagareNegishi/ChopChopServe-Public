extends MenuItem
class_name MacAndCheese

# Need to set ingredient list
# Need to make sure that the state of ingredients matches the state of the ingredient in the array
static var _auto_register = MenuItem.register(MacAndCheese)

func _ready():
	ingredients = ["Pasta", "Cheese"]
	
	ingredient_states = {
		"Pasta": ["RAW","BOILED","BAKED"],
		"Cheese": ["RAW", "BLENDED", "BAKED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
