extends Node
class_name generateOrder
# variables for the menuitem to be loaded into this script so its values can be used
var menu_instance

# Order for the npc
var order =[]

# new lists
var s = [] # starters
var m = [] # mains
var d = [] # deserts

var available_recipes: Array
# Creates an order of food that is available for the npcs to order depending on the day
# the server deals with the chnaging of the availablity at the moment
# @return an order of 2 starters, 2 mains and a desert in a list
func get_order():
	available_recipes = GameState.get_available_recipes()
	order.clear() # Make sure there is nothing in the list already as precaution
	
	# Put available food into new lists
	check_food_avalibility(s, MI.starters)
	check_food_avalibility(m, MI.mains)
	check_food_avalibility(d, MI.deserts)

	# Put the order together
	if !s.is_empty():
		order.append(random_food_generator(s))
		order.append(random_food_generator(s))
	
	if !m.is_empty():
		order.append(random_food_generator(m))
		order.append(random_food_generator(m))
	
	if !d.is_empty():
		order.append(random_food_generator(d))
	
	if order == null:
		push_error("There is nothing to be ordered, no recipes/menu items are avalible")
	
	return order


func get_simple_order(starter_index: int):
	var new_order = []
	check_food_avalibility(s, MI.starters)
	# Put the order together
	
	if !s.is_empty():
		new_order.append(food_generator(s, starter_index))
	
	return new_order

# Gets a random menuItem from a passed list
# @param food_type is an array list of available food items of a certain type
# @return a menuitem
func random_food_generator(food_type: Array)-> MenuItem:
	if food_type.size() < 1:
		return
	return food_type.pick_random()

## Method added to move randomisation into customer
func food_generator(food_type: Array, index : int)-> MenuItem:
	if food_type.size() < 1:
		return
	index = index % food_type.size()
	return food_type[index]


# Puts the available food_types into new arrays so that the npcs dont have access to anything they shouldn't
# @param new_list which is the list the available food goes into
# @param original_list is the static list from the menuitem class
func check_food_avalibility(new_list: Array, original_list: Array):
	new_list.clear()
	for item in available_recipes:
		if original_list.has(item):
			new_list.append(item)
