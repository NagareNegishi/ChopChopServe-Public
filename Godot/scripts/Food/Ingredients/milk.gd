extends Food
class_name Milk

func _ready():
	food_name = "Milk"
	raw_mesh = $Milk
	mixed_mesh = $Milk
	spoiled_mesh = null
	cooked_mesh = null
	burnt_mesh = null
	chopped_mesh = null
	add_to_group("Food")
	on_state_change()
	# Spoil time same as super class
