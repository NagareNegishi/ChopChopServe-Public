extends Food
class_name Beef

func _ready():
	food_name = "Beef"
	cook_time = 100
	spoil_time = 100
	raw_mesh = null
	spoiled_mesh = null
	cooked_mesh = null
	burnt_mesh = null
	chopped_mesh = null
	# Can cook is same as super class
