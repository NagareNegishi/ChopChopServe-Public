extends Food
class_name Tomato

# Sets the variables for tomato that are different to the superclass 


func _ready():
	food_name = "Tomato"
	raw_mesh = $Tomato
	spoiled_mesh = $SpoiledTomato
	cooked_mesh = $Tomato
	burnt_mesh = $BurntTomato
	chopped_mesh = $ChoppedTomato
	mixed_mesh = $ChoppedTomato
	texture = preload("res://assets/textures/ingredients/Tomato.png")
	add_to_group("Food")
	on_state_change()
