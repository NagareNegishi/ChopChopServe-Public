extends Food
class_name Strawberry

func _ready():
	food_name = "Strawberry"
	raw_mesh = null
	spoiled_mesh = null
	cooked_mesh = null
	burnt_mesh = null
	chopped_mesh = null
	texture = preload("res://assets/textures/ingredients/strawberry.png")
	add_to_group("Food")
	on_state_change()
