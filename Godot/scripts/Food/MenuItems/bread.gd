extends MenuItem
class_name bread

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(bread)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.starters, bread.new())

func _init():
	ingredients = ["Dough"]
	
	ingredient_states = {
		"Dough": ["RAW", "BAKED"]
	}
	name_of_meal = "bread"
	ui_texture = load("res://assets/textures/recipes/Bread.png")
func _ready():
	cooked_mesh_good = $BreadPlain
	cooked_mesh_bad = $BadQualityPlainBread
	cooked_mesh_burnt = $BurntPlainBread
	
