extends Food
class_name Cheese

func _ready():
	food_name = "Cheese"
	spoil_time = 100
	# cook time is same as super class
	# can cook is same as super class
	raw_mesh = null
	spoiled_mesh = null
	cooked_mesh = null
	burnt_mesh = null
	chopped_mesh = null
