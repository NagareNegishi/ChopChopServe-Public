extends Food
class_name Onion

func _ready():
	food_name = "Onion"
	raw_mesh = $Onion
	spoiled_mesh = $SpoiledOnion
	cooked_mesh = $ChoppedOnion
	burnt_mesh = $BurntOnion
	chopped_mesh = $ChoppedOnion
	# Cook time same as super class
	# Spoil time same as super class
	
	add_to_group("Food")
	on_state_change()
