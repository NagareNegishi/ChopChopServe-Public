extends Food
class_name Flour

func _ready():
	food_name = "Flour"
	spoil_time = null
	raw_mesh = $Flour
	mixed_mesh = $Flour
	spoiled_mesh = null
	cooked_mesh = null
	burnt_mesh = null
	chopped_mesh = null
	previous_states = ["RAW","MIXED"]
	add_to_group("Food")
	on_state_change()
