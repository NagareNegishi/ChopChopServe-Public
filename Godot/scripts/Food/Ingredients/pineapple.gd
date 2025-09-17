extends Food
class_name Pineapple

func _ready():
	food_name = "Pineapple"
	raw_mesh = $Pineapple
	spoiled_mesh = $SpoiledPineapple
	cooked_mesh = $PineappleSliced
	burnt_mesh = $BurntPineapple
	chopped_mesh = $PineappleSliced
	# Spoil time is same as super class
	# Cook time is same as super class
	
	add_to_group("Food")
	on_state_change()
