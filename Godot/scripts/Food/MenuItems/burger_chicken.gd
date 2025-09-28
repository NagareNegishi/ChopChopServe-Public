extends MenuItem
class_name ChickenBurger

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(ChickenBurger)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, ChickenBurger.new())

func _init():
	ingredients = ["Dough", "Cheese", "Tomato","Chicken"]
	
	ingredient_states = {
		"Dough": ["RAW", "BAKED"],
		"Cheese": ["RAW","CHOPPED"],
		"Tomato": ["RAW","CHOPPED"],
		"Chicken":["RAW","FRIED"]
	}
	
	is_available=true


func _ready():
	cooked_mesh_good = $BurgerChicken
	cooked_mesh_bad = $BadQualityChickenBurger
	cooked_mesh_burnt = $BurntChickenBurger
	ui_texture = load("res://assets/textures/recipes/ChickenBurger.png")
