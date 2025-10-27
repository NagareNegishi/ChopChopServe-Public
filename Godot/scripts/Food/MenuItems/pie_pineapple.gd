extends MenuItem
class_name pie_pineapple

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(pie_pineapple)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.deserts, pie_pineapple.new())

func _init():
	ingredients = ["Dough","Pineapple"]
	diffuculty = 1
	cost = 150
	ingredient_states = {
		"Pineapple": ["RAW","CHOPPED", "BAKED"],
		"Dough": ["RAW", "BAKED"]
	}
	ui_meal_name = "Pineapple Pie"
	ui_states = {
		"Dough":["NONE", "BAKED"],
		"Pineapple":["CHOPPED","BAKED"],
	}
	name_of_meal = "pie_pineapple"
	ui_texture = load("res://assets/textures/recipes/PineapplePie.png")

func _ready():
	cooked_mesh_good = $PiePineapple
	cooked_mesh_bad = $BadQualityPineapplePie
	cooked_mesh_burnt = $BurntPineapplePie
