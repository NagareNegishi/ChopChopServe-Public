extends Node

var preload_menuItems = preload("res://scripts/Food/MenuItems/menuItem.gd")
var menu_instance

var current_day : int # Need to update this each time the day chnages
var order =[]
func _ready():
	menu_instance = preload_menuItems.new()

func get_order():
	order.append(random_food_generator(menu_instance.starters))
	order.append(random_food_generator(menu_instance.starters))
	order.append(random_food_generator(menu_instance.mains))
	order.append(random_food_generator(menu_instance.mains))
	order.append(random_food_generator(menu_instance.deserts))
	
	check_food_avalibility(order)

func random_food_generator(food_type: Array)-> MenuItem:
	var size = food_type.size()
	var rand = randi % size
	return food_type.get(rand)

func check_food_avalibility(order_list: Array):
	return 0
