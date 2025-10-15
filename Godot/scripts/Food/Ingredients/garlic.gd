class_name Garlic
extends Food

func _ready():
	food_name = "Garlic"
	spoil_time = 150
	raw_mesh = $Garlic
	spoiled_mesh = $SpoiledGarlic
	cooked_mesh = $Garlic
	burnt_mesh = $BurntGarlic
	chopped_mesh = $GarlicChopped
	texture = preload("res://assets/textures/ingredients/garlic.png")
	add_to_group("Food")
	on_state_change()
