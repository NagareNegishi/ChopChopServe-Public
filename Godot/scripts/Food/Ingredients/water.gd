extends Food
class_name Water

func _ready():
	food_name = "Water"
	spoil_time = null
	raw_mesh = $raw
	
	add_to_group("Food")
	on_state_change()
