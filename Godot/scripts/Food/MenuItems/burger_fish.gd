extends MenuItem
class_name FishBurger

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(FishBurger)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, FishBurger.new())

func _init():
	ingredients = ["Dough", "Cheese", "Tomato","Fish"]
	
	ingredient_states = {
		"Dough": ["RAW", "BAKED"],
		"Cheese": ["RAW","CHOPPED"],
		"Tomato": ["RAW","CHOPPED"],
		"Fish":["RAW","FRIED"]
	}
	
	is_available=true

func _ready():
	cooked_mesh_good = $BurgerFish
	cooked_mesh_bad = $BadQaulityFishBurger
	cooked_mesh_burnt = $BurntFishBurger
	ui_texture = load("res://assets/textures/recipes/FishBurger.png")
