extends Node

# variables for the menuitem to be loaded into this script so its values can be used
var preload_menuItems = preload("res://scripts/Food/MenuItems/menuItem.gd")
var menu_instance

# Order for the npc
var order =[]

# new lists
var s = [] # starters
var m = [] # mains
var d = [] # deserts


# Instantiates a new instance of the menuitem so that there is access to the menuitem static arrays
func _ready():
	menu_instance = preload_menuItems.new()


# Creates an order of food that is available for the npcs to order depending on the day
# the server deals with the chnaging of the availablity at the moment
# @return an order of 2 starters, 2 mains and a desert in a list
func get_order():
	order.clear() # Make sure there is nothing in the list already as precaution
	
	# Put available food into new lists
	check_food_avalibility(s, menu_instance.starters)
	check_food_avalibility(m, menu_instance.mains)
	check_food_avalibility(d, menu_instance.deserts)
	
	# Put the order together
	order.append(random_food_generator(s))
	order.append(random_food_generator(s))
	order.append(random_food_generator(m))
	order.append(random_food_generator(m))
	order.append(random_food_generator(d))
	
	return order


# Gets a random menuItem from a passed list
# @param food_type is an array list of available food items of a certain type
# @return a menuitem
func random_food_generator(food_type: Array)-> MenuItem:
	var size = food_type.size()-1
	var rand = randi % size
	return food_type.get(rand)


# Puts the available food_types into new arrays so that the npcs dont have access to anything they shouldn't
# @param new_list which is the list the available food goes into
# @param original_list is the static list from the menuitem class
func check_food_avalibility(new_list: Array, original_list: Array):
	new_list.clear()
	for item in original_list:
		if item.is_available:
			new_list.append(item)
