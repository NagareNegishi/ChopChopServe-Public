extends MenuItem
class_name StrawberryIcecream

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(StrawberryIcecream)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.deserts, StrawberryIcecream)

func _ready():
	ingredients = ["Vanilla Icecream", "Strawberry","Strawberry","Strawberry"]
	
	ingredient_states = {
		"Vanilla Icecream": ["RAW","BLENDED"],
		"Strawberry": ["RAW","CHOPPED","BLENDED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
