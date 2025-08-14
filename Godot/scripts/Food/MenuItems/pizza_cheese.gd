extends MenuItem
class_name CheesePizza

# Need to set ingredient list
# Need to make sure that the state of ingredients matches the state of the ingredient in the array
static var _auto_register = MenuItem.register(CheesePizza)

func _ready():
	ingredients = ["Dough", "Cheese", "Tomato"]
	
	ingredient_states = {
		"Dough": ["RAW","ROLLED", "BAKED"],
		"Cheese": ["RAW","BLENDED","BAKED"],
		"Tomato": ["RAW","CHOPPED","BAKED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
