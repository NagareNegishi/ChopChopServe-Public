extends MenuItem
class_name ChocolateIcecream

# Need to set ingredient list
# Need to make sure that the state of ingredients matches the state of the ingredient in the array
static var _auto_register = MenuItem.register(ChocolateIcecream)
func _ready():
	ingredients = ["Vanilla Icecream", "Cocoa"]
	
	ingredient_states = {
		"Vanilla Icecream": ["RAW","BLENDED"],
		"Cocoa": ["RAW","BLENDED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
