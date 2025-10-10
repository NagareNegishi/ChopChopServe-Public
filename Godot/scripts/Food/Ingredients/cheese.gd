extends Food
class_name Cheese

func _ready():
	food_name = "Cheese"
	spoil_time = 100
	raw_mesh = $Cheese
	spoiled_mesh = $SpoiledCheese
	cooked_mesh = $Cheese
	burnt_mesh = $BurntCheese
	chopped_mesh = $CheeseSliced
	texture = load("res://assets/textures/ingredients/cheese.png")
	
	add_to_group("Food")
	on_state_change()
