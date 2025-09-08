extends Food
class_name Pumpkin

func _ready():
	food_name = "Pummpkin"
	raw_mesh = $Pumpkin
	spoiled_mesh = null
	cooked_mesh = null
	burnt_mesh = null
	chopped_mesh = null
	# Cook time same as super class
	# Spoil time same as super class
	
	add_to_group("Food")
	on_state_change()
