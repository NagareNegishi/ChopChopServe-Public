extends MenuItem
class_name taco_mushroom

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(taco_mushroom)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, taco_mushroom.new())


func _init():
	ingredients = ["Dough", "Mushroom", "Tomato"]
	diffuculty = 2
	cost = 190
	ingredient_states = {
		"Mushroom": ["RAW","CHOPPED","FRIED"],
		"Dough": ["RAW", "BAKED"],
		"Tomato":["RAW","CHOPPED"]
	}
	
	name_of_meal = "taco_mushroom"
	ui_texture = load("res://assets/textures/recipes/MushroomTaco.png")
	ui_meal_name = "Mushroom Taco"
	ui_states = {
		"Dough":["NONE","BAKED"],
		"Mushroom":["CHOPPED", "FRIED"],
		"Tomato":["CHOPPED","NONE"]
	}
func _ready():
	cooked_mesh_good = $TacoMushroom
	cooked_mesh_bad = $BadQualityMushTaco
	cooked_mesh_burnt = $BurntMushTaco
	GlobalScript.tutorial_step.emit(14)
