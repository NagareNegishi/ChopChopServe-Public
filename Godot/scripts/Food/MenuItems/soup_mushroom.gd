extends MenuItem
class_name MushroomSoup

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(MushroomSoup)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.starters, MushroomSoup.new())

func _init():
	ingredients = ["Mushroom", "Mushroom", "Mushroom", "Water"]
	
	ingredient_states = {
		"Mushroom": ["RAW","CHOPPED", "BOILED"],
		"Water": ["RAW","BOILED"]
	}
	
	is_available = true

func _ready():
	cooked_mesh_good = $SoupMushroom
	cooked_mesh_bad = $BadQualityMushSoup
	cooked_mesh_burnt = $BurntSoup
	ui_texture = load("res://assets/textures/recipes/MushroomSoup.png")
