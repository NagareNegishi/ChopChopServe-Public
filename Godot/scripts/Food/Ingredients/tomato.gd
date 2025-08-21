extends Food
class_name Tomato

# Sets the variables for tomato that are different to the superclass 


func _ready():
	food_name = "Tomato"
	raw_mesh = $RawTomato
	spoiled_mesh = null
	cooked_mesh = null
	burnt_mesh = null
	chopped_mesh = $ChoppedTomato
	# Spoil time is 80 which is same as super class
	# Cook time is 50 which is same as super class
	# Can cook is true same as super class
	
	#previous_states=["RAW","CHOPPED", "BOILED"]
	#state = foodState.CHOPPED
	add_to_group("Food")
	on_state_change()
# State of the food changes in the super class
