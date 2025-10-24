extends MenuItem
class_name icecream_strawberry

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(icecream_strawberry)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.deserts, icecream_strawberry.new())

func _init():
	ingredients = ["Vanilla Icecream", "Strawberry","Strawberry","Strawberry"]
	
	ingredient_states = {
		"Vanilla Icecream": ["RAW","BLENDED"],
		"Strawberry": ["RAW","BLENDED"]
	}
	
	name_of_meal = "icecream_strawberry"
	ui_texture = load("res://assets/textures/recipes/StrawberryIcecream.png")
	ui_meal_name = "Strawberry Icecream"

func _ready():
	cooked_mesh_good = $IceCreamStrawberry
	cooked_mesh_bad = $IceCreamStrawberry2
	cooked_mesh_burnt = null
