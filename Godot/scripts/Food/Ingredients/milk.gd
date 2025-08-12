extends Food
class_name Milk

func _ready():
	food_name = "Milk"
	cook_time = 30
	spoil_time=10
	raw_mesh = $rawMilk
	spoiled_mesh = $spoiledMilk
	cooked_mesh = null
	burnt_mesh = null
	chopped_mesh = null
	on_state_change()
	# Spoil time same as super class
