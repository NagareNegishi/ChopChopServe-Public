extends MenuItem
class_name Brownies

# Need to set ingredient list
# Need to make sure that the state of ingredients matches the state of the ingredient in the array
static var _auto_register = MenuItem.register(Brownies)
func _ready():
	ingredients = ["Flour", "Cocoa", "Milk"]
	
	ingredient_states = {
		"Flour": ["RAW","BLENDED"],
		"Cocoa": ["RAW","BLENDED"],
		"Milk": ["RAW", "BLENDED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
