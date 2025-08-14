extends MenuItem
class_name BeefTaco

# Need to set ingredient list
# Need to make sure that the state of ingredients matches the state of the ingredient in the array
static var _auto_register = MenuItem.register(BeefTaco)

func _ready():
	ingredients = ["Dough", "Beef", "Tomato"]
	
	ingredient_states = {
		"Beef": ["RAW","COOKED"],
		"Dough": ["RAW","ROLLED", "COOKED"],
		"Tomato":["RAW","CHOPPED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
