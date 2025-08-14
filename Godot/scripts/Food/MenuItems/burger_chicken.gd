extends MenuItem
class_name ChickenBurger

# Need to set ingredient list
# Need to make sure that the state of ingredients matches the state of the ingredient in the array
static var _auto_register = MenuItem.register(ChickenBurger)
func _ready():
	ingredients = ["Dough", "Cheese", "Tomato","Chicken"]
	
	ingredient_states = {
		"Dough": ["RAW","ROLLED", "BAKED"],
		"Cheese": ["RAW","CHOPPED"],
		"Tomato": ["RAW","CHOPPED"],
		"Chicken":["RAW","COOKED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
