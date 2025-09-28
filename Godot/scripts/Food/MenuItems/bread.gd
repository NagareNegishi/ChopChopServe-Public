extends MenuItem
class_name PlainBread

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(PlainBread)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.starters, PlainBread.new())

func _init():
	ingredients = ["Dough"]
	
	ingredient_states = {
		"Dough": ["RAW", "BAKED"]
	}
	is_available = true

func _ready():
	cooked_mesh_good = $BreadPlain
	cooked_mesh_bad = $BadQualityPlainBread
	cooked_mesh_burnt = $BurntPlainBread
	ui_texture = load("res://assets/textures/recipes/Bread.png")
