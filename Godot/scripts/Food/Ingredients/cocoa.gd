extends Food
class_name Cocoa

func _ready():
	food_name = "Cocoa"
	spoil_time = 150
	raw_mesh = $Cocoa
	mixed_mesh = $Cocoa
	texture = load("res://assets/textures/ingredients/cocoa.png")
	
	add_to_group("Food")
	on_state_change()
