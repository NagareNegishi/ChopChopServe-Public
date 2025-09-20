extends Food
class_name VanillaIcecream

func _ready():
	food_name = "Vanilla Icecream"
	spoil_time = 50
	# cook time is same as super class
	# can cook is same as super class
	raw_mesh = null
	add_to_group("Food")
	on_state_change()
