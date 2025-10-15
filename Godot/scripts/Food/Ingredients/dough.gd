extends Food
class_name Dough

func _ready():
	food_name = "Dough"
	spoil_time = 100
	raw_mesh = $dough
	spoiled_mesh = $SpoiledDough
	cooked_mesh = $dough
	burnt_mesh = $BurntDough
	texture = load("res://assets/textures/ingredients/dough.png")
	
	add_to_group("Food")
	on_state_change()
