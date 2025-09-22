extends Food
class_name Apple

func _ready():
	food_name = "Apple"
	raw_mesh = $Apple
	spoiled_mesh = $SpoiledApple
	cooked_mesh = $ChoppedApple
	burnt_mesh = $BurntApple
	chopped_mesh = $ChoppedApple
	
	add_to_group("Food")
	on_state_change()
