class_name Tomato
extends Food

# Sets the variables for tomato that are different to the superclass 
func _ready():
	food_name = "Tomato"
	raw_mesh = $raw
	spoiled_mesh = $spoiled
	cooked_mesh = null
	burnt_mesh = null
	chopped_mesh = null
	# Spoil time is 80 which is same as super class
	# Cook time is 50 which is same as super class
	# Can cook is true same as super class
	previous_states=["RAW","CHOPPED", "BOILED"]
	add_to_group("Food")
# State of the food changes in the super class
