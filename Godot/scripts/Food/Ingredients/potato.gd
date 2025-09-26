extends Food
class_name Potato

func _ready():
	food_name = "Potato"
	spoil_time = 150
	raw_mesh = $Potato
	spoiled_mesh = $SpoiledPotato
	cooked_mesh = $Potato
	burnt_mesh = $BurntPotato
	chopped_mesh = $ChoppedPotato
	
	add_to_group("Food")
	on_state_change()
