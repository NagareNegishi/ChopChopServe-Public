extends Food
class_name Potato

func _ready():
	food_name = "Potato"
	spoil_time = 150
	raw_mesh = null
	spoiled_mesh = null
	cooked_mesh = null
	burnt_mesh = null
	chopped_mesh = null
	# cook time same as super class
