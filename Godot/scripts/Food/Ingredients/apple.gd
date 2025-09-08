extends Food
class_name Apple

func _ready():
	food_name = "Apple"
	spoil_time = null
	raw_mesh = $Apple
	mixed_mesh = null
	spoiled_mesh = null
	cooked_mesh = null
	burnt_mesh = null
	chopped_mesh = null
	
	add_to_group("Food")
	on_state_change()
