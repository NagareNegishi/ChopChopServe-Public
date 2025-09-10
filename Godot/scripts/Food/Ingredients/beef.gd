extends Food
class_name Beef

func _ready():
	food_name = "Beef"
	spoil_time = 100
	raw_mesh = $Beef
	spoiled_mesh = null
	cooked_mesh = null
	burnt_mesh = null
	chopped_mesh = null
	# Can cook is same as super class
	
	add_to_group("Food")
	on_state_change()
