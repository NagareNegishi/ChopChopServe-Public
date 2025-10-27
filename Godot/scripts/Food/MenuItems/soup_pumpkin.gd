extends MenuItem
class_name soup_pumpkin

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(soup_pumpkin)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.starters, soup_pumpkin.new())

func _init():
	ingredients = ["Pumpkin", "Pumpkin", "Pumpkin"]
	diffuculty = 2
	cost = 150
	ingredient_states = {
		"Pumpkin": ["RAW","CHOPPED", "BOILED"],
	}
	
	name_of_meal = "soup_pumpkin"
	ui_texture = load("res://assets/textures/recipes/PumpkinSoup.png")
	ui_meal_name = "Pumpkin Soup"
	ui_states = {
		"Pumpkin1":["CHOPPED", "BOILED"],
		"Pumpkin2":["CHOPPED", "BOILED"],
		"Pumpkin3":["CHOPPED", "BOILED"]
	}
func _ready():
	cooked_mesh_good = $SoupPumpkin
	cooked_mesh_bad = $BadQualityPumpkinSoup
	cooked_mesh_burnt = $BurntSoup
