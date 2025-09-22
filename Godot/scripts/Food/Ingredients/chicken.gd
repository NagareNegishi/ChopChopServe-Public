extends Food
class_name Chicken

func _ready():
	food_name = "Chicken"
	spoil_time = 100
	# Can cook is same as super class
	raw_mesh = $Chicken
	spoiled_mesh = $SpoiledChicken
	cooked_mesh = $ChickenCooked
	burnt_mesh = $BurntChicken
	
	add_to_group("Food")
	on_state_change()
