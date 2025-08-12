extends Food
class_name Sauce

func _ready():
	food_name = "Sauce"
	spoil_time = 150
	raw_mesh = null
	spoiled_mesh = null
	cooked_mesh = null
	burnt_mesh = null
	chopped_mesh = null
	# Can cook is same as super class
