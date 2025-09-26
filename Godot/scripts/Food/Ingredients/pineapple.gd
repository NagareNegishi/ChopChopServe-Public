extends Food
class_name Pineapple

func _ready():
	food_name = "Pineapple"
	raw_mesh = $Pineapple
	spoiled_mesh = $SpoiledPineapple
	cooked_mesh = $Pineapple
	burnt_mesh = $BurntPineapple
	chopped_mesh = $PineappleSliced
	
	add_to_group("Food")
	on_state_change()
