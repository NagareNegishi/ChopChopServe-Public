extends MenuItem
class_name burger_fish

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(burger_fish)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.mains, burger_fish.new())

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
	name_of_meal = "burger_fish"
	ui_texture = load("res://assets/textures/recipes/FishBurger.png")
