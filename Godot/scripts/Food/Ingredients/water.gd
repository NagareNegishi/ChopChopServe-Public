extends Food
class_name Water

func _ready():
	food_name = "Water"
	spoil_time = null
	raw_mesh = $raw
	spoiled_mesh = null
	cooked_mesh = null
	burnt_mesh = null
	chopped_mesh = null
	add_to_group("Food")
	#previous_states = ["RAW","BOILED"]
	on_state_change()
