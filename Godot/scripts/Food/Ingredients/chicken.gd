extends Food
class_name Chicken

func _ready():
	food_name = "Chicken"
	cook_time = 100
	spoil_time = 100
	# Can cook is same as super class
	raw_mesh = null
	spoiled_mesh = null
	cooked_mesh = null
	burnt_mesh = null
	chopped_mesh = null
