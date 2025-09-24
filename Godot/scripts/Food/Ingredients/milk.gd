extends Food
class_name Milk

func _ready():
	food_name = "Milk"
	raw_mesh = $Milk
	mixed_mesh = $Milk
	
	add_to_group("Food")
	on_state_change()
