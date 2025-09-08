extends Food
class_name Onion

func _ready():
	food_name = "Onion"
	raw_mesh = $Onion
	spoiled_mesh = null
	cooked_mesh = $Onion
	burnt_mesh = null
	chopped_mesh = $ChoppedOnion
	# Cook time same as super class
	# Spoil time same as super class
	
	add_to_group("Food")
	on_state_change()
