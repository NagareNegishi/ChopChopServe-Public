extends Object

var food_items = {}
var ingredients = IngredientsEnum.Ingredients
var dish = DishEnum.new()

# Adds items to the plate
func add_item(_ingredient):
	if ingredients.has(_ingredient) && ingredients[_ingredient]["is_prepared"]:
		food_items.append(_ingredient)
		check_plate()

# This has been made so that we can add the different ingredients to the plate visually
func get_items():
	return food_items

# This is so that if they make a mistake they have to bin the whole thing
# We can change this later if you want them to be able to take off the top item
func remove_all():
	food_items.clear()

# This checks if the plate contains a dish, when it does contain a dish it removes everything and
# replaces the list of ingredients with a dish
func check_plate():
	if food_items.is_empty():
		return 0
	
	for d in DishEnum.DishType.values():
		var required_ingredients = dish.dish_ingredients[d]
		if contains_all(required_ingredients, food_items):
			food_items.clear()
			food_items.append(d)

# Compares the 2 list, one of them is the ingredients required to make a dish
# the other list is the ingredients we have
func contains_all(list1, list2):
	if list1.size() != list2.size():
		return false
	
	# They should get sorted in the same way if they have the same enum types in them
	list1.sort()
	list2.sort()
	
	for i in list1.size():
		if ingredients[list1.get(i)]["name"] != ingredients[list2.get(i)]["name"]:
			return false
	
	return true
