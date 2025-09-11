extends Food
class_name Mushroom

func _ready():
	food_name = "Mushroom"
	spoil_time = 70
	raw_mesh = $Mushroom
	spoiled_mesh = $SpoiledMushroom
	cooked_mesh = $MushroomChopped
	burnt_mesh = $BurntMushroom
	chopped_mesh = $MushroomChopped
	# coook time is 50 same as super class
	# can cook is true same as super class
	
	add_to_group("Food")
	on_state_change()
