extends Food
class_name Cocoa

func _ready():
	food_name = "Cocoa"
	spoil_time = 150
	raw_mesh = $Cocoa
	mixed_mesh = $Cocoa
	previous_states = ["RAW", "MIXED"]
	add_to_group("Food")
	on_state_change()
