extends Food
class_name Potato

func _ready():
	food_name = "Potato"
	spoil_time = 150
	raw_mesh = $Potato
	spoiled_mesh = $SpoiledPotato
	cooked_mesh = $Potato
	burnt_mesh = $BurntPotato
	chopped_mesh = $ChoppedPotato
	texture = preload("res://assets/textures/ingredients/potato.png")
	add_to_group("Food")
	on_state_change()
