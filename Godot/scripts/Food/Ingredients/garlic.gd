class_name Garlic
extends Food

func _ready():
	food_name = "Garlic"
	spoil_time = 150
	raw_mesh = $Garlic
	spoiled_mesh = $SpoiledGarlic
	cooked_mesh = $GarlicChopped
	burnt_mesh = $BurntGarlic
	chopped_mesh = $GarlicChopped
	# Cook_time is 50 same as super class
	# Can cook is true same as super class
	
	add_to_group("Food")
	on_state_change()
