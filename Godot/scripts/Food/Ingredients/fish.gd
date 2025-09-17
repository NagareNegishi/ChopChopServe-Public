extends Food
class_name Fish

func _ready():
	food_name = "Fish"
	spoil_time = 100
	raw_mesh = $Fish
	spoiled_mesh = $SpoiledFish
	cooked_mesh = $CookedFish
	burnt_mesh = $BurntFish
	
	
	add_to_group("Food")
	on_state_change()
