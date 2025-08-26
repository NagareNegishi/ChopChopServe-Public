extends MenuItem
class_name Bread

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(Bread)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.starters, Bread.new())

func _ready():
	ingredients = ["Dough"]
	
	ingredient_states = {
		"Dough": ["RAW","ROLLED", "BAKED"]
	}
	
	cooked_mesh_good = null
	cooked_mesh_bad = null
	cooked_mesh_burnt = null
