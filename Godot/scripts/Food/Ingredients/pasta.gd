extends Food
class_name Pasta

func _ready():
	food_name = "Pasta"
	raw_mesh = $Pasta
	spoiled_mesh = $SpoiledPasta
	cooked_mesh = $Pasta
	burnt_mesh = $BurntPasta
	texture = preload("res://assets/textures/ingredients/pasta.png")
	add_to_group("Food")
	on_state_change()
