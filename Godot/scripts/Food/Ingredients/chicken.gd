extends Food
class_name Chicken

func _ready():
	food_name = "Chicken"
	spoil_time = 100
	raw_mesh = $Chicken
	spoiled_mesh = $SpoiledChicken
	cooked_mesh = $ChickenCooked
	burnt_mesh = $BurntChicken
	texture = load("res://assets/textures/ingredients/chicken.png")
	
	add_to_group("Food")
	on_state_change()
