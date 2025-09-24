extends MenuItem
class_name TomatoSoup

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(TomatoSoup)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.starters, TomatoSoup.new())

func _init():
	ingredients = ["Tomato","Tomato","Tomato", "Water"]
	
	ingredient_states = {
		"Tomato": ["RAW","CHOPPED", "BOILED"],
		"Water": ["RAW","BOILED"]
	}
	is_available = true

	# This is the appliance it is to be collected in 
	#appliance = "Bowl"
	name_of_meal = "TomatoSoup"
	ui_texture = load("res://assets/textures/recipes/TomatoSoup.png")

func _ready():
	cooked_mesh_good = $TomatoSoup
	cooked_mesh_bad = $BadQualityTomatoSoup
	cooked_mesh_burnt = $BurntTomatoSoup
	ui_texture = load("res://assets/textures/recipes/TomatoSoup.png")
