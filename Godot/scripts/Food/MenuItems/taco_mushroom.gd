extends MenuItem
class_name MushroomTaco

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(MushroomTaco)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, MushroomTaco.new())


func _init():
	ingredients = ["Dough", "Mushroom", "Tomato"]
	
	ingredient_states = {
		"Mushroom": ["RAW","CHOPPED","FRIED"],
		"Dough": ["RAW", "BAKED"],
		"Tomato":["RAW","CHOPPED"]
	}
	
	is_available= true

func _ready():
	cooked_mesh_good = $TacoMushroom
	cooked_mesh_bad = $BadQualityMushTaco
	cooked_mesh_burnt = $BurntMushTaco
	ui_texture = load("res://assets/textures/recipes/MushroomTaco.png")
