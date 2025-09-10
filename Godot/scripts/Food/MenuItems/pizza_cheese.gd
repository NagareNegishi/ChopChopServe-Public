extends MenuItem
class_name CheesePizza

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(CheesePizza)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, CheesePizza.new())

func _init():
	ingredients = ["Dough", "Cheese", "Tomato"]
	
	ingredient_states = {
		"Dough": ["RAW", "BAKED"],
		"Cheese": ["RAW","CHOPPED","BAKED"],
		"Tomato": ["RAW","MIXED","BAKED"]
	}
	
	is_available = true

func _ready():
	cooked_mesh_good = $PizzaCheese
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
