extends MenuItem
class_name MushroomSoup

# Need to set ingredient list
# Need to make sure that the state of ingredients matches the state of the ingredient in the array

func _ready():
	ingredients = ["Mushroom", "Mushroom", "Mushroom", "Water"]
	
	ingredient_states = {
		"Mushroom": ["RAW","CHOPPED", "BOILED"],
		"Water": ["RAW","BOILED"]
	}
	
	# This is the appliance it is to be collected in 
	appliance = "Bowl"
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
