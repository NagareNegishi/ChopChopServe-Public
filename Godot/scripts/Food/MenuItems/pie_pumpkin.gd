extends MenuItem
class_name PumpkinPie

# Need to set ingredient list
# Need to make sure that the state of ingredients matches the state of the ingredient in the array
static var _auto_register = MenuItem.register(PumpkinPie)

func _ready():
	ingredients = ["Dough","Pumpkin"]
	
	ingredient_states = {
		"Pumpkin": ["RAW","CHOPPED", "BAKED"],
		"Dough": ["RAW","ROLLED", "BAKED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
