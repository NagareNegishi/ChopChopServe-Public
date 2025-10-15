extends Food
class_name Mushroom

func _ready():
	food_name = "Mushroom"
	spoil_time = 70
	raw_mesh = $Mushroom
	spoiled_mesh = $SpoiledMushroom
	cooked_mesh = $Mushroom
	burnt_mesh = $BurntMushroom
	chopped_mesh = $MushroomChopped
	texture = preload("res://assets/textures/ingredients/mushroom.png")
	add_to_group("Food")
	on_state_change()
