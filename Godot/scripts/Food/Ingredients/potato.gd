extends Food
class_name Potato

func _ready():
	food_name = "Potato"
	spoil_time = 150
	raw_mesh = $Potato
	spoiled_mesh = null
	cooked_mesh = null
	burnt_mesh = null
	chopped_mesh = $PotatoChips
	# cook time same as super class
	
	add_to_group("Food")
	on_state_change()
