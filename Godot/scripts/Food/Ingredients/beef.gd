extends Food
class_name Beef

func _ready():
	food_name = "Beef"
	spoil_time = 100
	raw_mesh = $Beef
	spoiled_mesh = $SpoiledBeef
	cooked_mesh = $BeefCooked
	burnt_mesh = $BurntBeef
	
	add_to_group("Food")
	on_state_change()
