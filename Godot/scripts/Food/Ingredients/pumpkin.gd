extends Food
class_name Pumpkin

func _ready():
	food_name = "Pummpkin"
	raw_mesh = $Pumpkin
	spoiled_mesh = $SpoiledPumpkin
	cooked_mesh = $Pumpkin
	burnt_mesh = $BurntPumpkin
	chopped_mesh = $ChoppedPumpkin
	# Cook time same as super class
	# Spoil time same as super class
	texture = preload("res://assets/textures/ingredients/pumpkin.png")
	add_to_group("Food")
	on_state_change()
