extends MenuItem
class_name MeatPizza

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(MeatPizza)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, MeatPizza.new())

func _init():
	ingredients = ["Dough", "Cheese", "Tomato", "Beef"]
	
	ingredient_states = {
		"Dough": ["RAW","ROLLED", "BAKED"],
		"Cheese": ["RAW","BLENDED","BAKED"],
		"Tomato": ["RAW","CHOPPED","BAKED"],
		"Beef":["RAW", "COOKED", "BAKED"]
	}
	
	is_available=true


func _ready():
	cooked_mesh_good = $PizzaPep
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
