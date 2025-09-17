extends Food
class_name Potato

func _ready():
	food_name = "Potato"
	spoil_time = 150
	raw_mesh = $Potato
	spoiled_mesh = $SpoiledPotato
	cooked_mesh = $ChoppedPotato
	burnt_mesh = $BurntPotato
	chopped_mesh = $PotatoChips
	# cook time same as sxuper class
	
	
	add_to_group("Food")
	on_state_change()
