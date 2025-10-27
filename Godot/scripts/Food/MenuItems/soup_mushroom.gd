extends MenuItem
class_name soup_mushroom

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(soup_mushroom)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.starters, soup_mushroom.new())

func _init():
	ingredients = ["Mushroom", "Mushroom", "Mushroom"]
	diffuculty = 2
	cost = 150
	ingredient_states = {
		"Mushroom": ["RAW","CHOPPED", "BOILED"]
	}
	
	name_of_meal = "soup_mushroom"
	ui_texture = load("res://assets/textures/recipes/MushroomSoup.png")
	ui_meal_name = "Mushroom Soup"
	ui_states = {
		"Mushroom1":["CHOPPED", "BOILED"],
		"Mushroom2":["CHOPPED","BOILED"],
		"Mushroom3":["CHOPPED","BOILED"]
	}
func _ready():
	cooked_mesh_good = $SoupMushroom
	cooked_mesh_bad = $BadQualityMushSoup
	cooked_mesh_burnt = $BurntSoup
