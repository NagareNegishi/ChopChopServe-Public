extends MenuItem
class_name ApplePie

# Need to set ingredient list
# Need to make sure that the state of ingredients matches the state of the ingredient in the array
static var _auto_register = MenuItem.register(ApplePie)

func _ready():
	ingredients = ["Dough","Apple"]
	
	ingredient_states = {
		"Apple": ["RAW","CHOPPED", "BAKED"],
		"Dough": ["RAW","ROLLED", "BAKED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
