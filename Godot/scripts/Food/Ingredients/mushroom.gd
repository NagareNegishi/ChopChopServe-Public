extends Food
class_name Mushroom

func _ready():
	food_name = "Mushroom"
	spoil_time = 70
	raw_mesh = null
	spoiled_mesh = null
	cooked_mesh = null
	burnt_mesh = null
	chopped_mesh = null
	# coook time is 50 same as super class
	# can cook is true same as super class
