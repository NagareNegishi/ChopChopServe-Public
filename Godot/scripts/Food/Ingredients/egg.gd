extends Food
class_name Egg

func _ready():
	food_name = "Egg"
	raw_mesh = $Egg
	cooked_mesh = $Egg
	
	add_to_group("Food")
	on_state_change()
