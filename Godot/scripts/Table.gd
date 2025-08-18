class_name Table extends Occupiable
@export var current_food: MenuItem = null

func get_food():
	return current_food

## Adds an item of food to the table
func add_food(food: MenuItem):
	current_food = food

func remove_food():
	current_food.queue_free()
	current_food = null
