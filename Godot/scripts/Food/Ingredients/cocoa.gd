extends Food
class_name Cocoa

func _ready():
	food_name = "Cocoa"
	spoil_time = 150
	raw_mesh = $Cocoa
	mixed_mesh = $Cocoa
	add_to_group("Food")
	on_state_change()
	
	print("Name of ingredient: ", food_name, " Position: ", global_position, " ID: ", ENetManager.get_my_id())
