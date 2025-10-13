extends MenuItem
class_name soup_tomato

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(soup_tomato)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.starters, soup_tomato.new())

func _init():
	ingredients = ["Tomato","Tomato","Tomato"]
	
	ingredient_states = {
		"Tomato": ["RAW","CHOPPED", "BOILED"],
	}
	is_available = true
	name_of_meal = "soup_tomato"
	ui_texture = load("res://assets/textures/recipes/TomatoSoup.png")

	# This is the appliance it is to be collected in 
	#appliance = "Bowl"

func _ready():
	cooked_mesh_good = $TomatoSoup
	cooked_mesh_bad = $BadQualityTomatoSoup
	cooked_mesh_burnt = $BurntTomatoSoup
