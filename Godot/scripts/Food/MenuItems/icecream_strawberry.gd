extends MenuItem
class_name StrawberryIcecream

# Registers this class in the correct arrays in the superclass
@warning_ignore("unused_private_class_variable")
static var _auto_register = MenuItem.register(StrawberryIcecream)
@warning_ignore("unused_private_class_variable")
static var _type_register = MenuItem.register_type(MenuItem.deserts, StrawberryIcecream.new())

func _init():
	ingredients = ["Vanilla Icecream", "Strawberry","Strawberry","Strawberry"]
	
	ingredient_states = {
		"Vanilla Icecream": ["RAW","BLENDED"],
		"Strawberry": ["RAW","BLENDED"]
	}
	
	is_available=true


func _ready():
	cooked_mesh_good = $IceCreamStrawberry
	cooked_mesh_bad = $IceCreamStrawberry2
	cooked_mesh_burnt = null
