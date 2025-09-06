extends Food
class_name Fish

func _ready():
	food_name = "Fish"
	spoil_time = 100
	raw_mesh = $Fish
	spoiled_mesh = null
	cooked_mesh = $cooked_fish
	burnt_mesh = null
	chopped_mesh = null
	
	add_to_group("Food")
	on_state_change()
