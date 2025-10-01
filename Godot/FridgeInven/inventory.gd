extends Control

@export var layer_depth: int = 100

var is_open: bool = false
@onready var gridCont = $ColorRect/GridContainer

var SlotScene := preload("res://FridgeInven/slot.tscn")

var columns : int = 5
var slots : int = 20
var current_slot = 0

func _ready():
	gridCont.columns = columns
	set_up_inven()
	close()

func _process(_delta):
	if !is_open:
		update_slot_selected(false)
		current_slot = 0

func _input(event):
	
	if is_open:
		if event.is_action_pressed("Right"):
			current_slot = move_forward()
		if event.is_action_pressed("Left"):
			current_slot = move_backward()
		if event.is_action_pressed("Up"):
			current_slot = move_up()
		if event.is_action_pressed("Down"):
			current_slot = move_down()
		
		update_slot_selected(true)
		
		if event.is_action_pressed("Interact"):
			select_ingredient()

# Have these called by the fridge so it can open and close the inventory
func open():
	visible = true
	is_open = true

func close():
	visible = false
	is_open = false

func set_up_inven():
	add_slot("tomato", 5, 5)
	add_slot("apple", 3, 5)
	add_slot("pineapple", 2, 4)
	add_slot("pumpkin", 2, 4)
	add_slot("strawberry", 3, 3)
	add_slot("cocoa", 2, 5)
	add_slot("dough", 5, 5)
	add_slot("pasta", 2, 5)
	add_slot("flour", 2, 5)
	add_slot("fish", 4, 5)
	add_slot("ham", 2, 5)
	add_slot("beef", 2, 5)
	add_slot("chicken", 3, 5)
	add_slot("egg", 2, 5)
	add_slot("milk", 3, 5)
	add_slot("cheese", 5, 5)
	add_slot("mushroom", 5, 5)
	add_slot("onion", 5, 5)
	add_slot("garlic", 5, 5)
	add_slot("potato", 5, 5)
	

func add_slot(item_name: String, amount: int, price: int):
	var slot_instance = SlotScene.instantiate()
	slot_instance.call_deferred("assign_item_text", get_2D_texture(item_name))
	slot_instance.inventory_item_name = item_name
	slot_instance.amount = amount
	slot_instance.price = price

	# Try to connect to parent FoodFactory
	var canvas_layer = get_parent()
	var food_factory = canvas_layer.get_parent()
	if food_factory and food_factory is FoodFactory:
		slot_instance.food_requested.connect(food_factory._on_food_selected)
	else:
		print("ERROR: Could not find FoodFactory parent")
	
	gridCont.add_child(slot_instance)


func get_2D_texture(item_name: String) -> Texture2D:
	return load("res://assets/textures/ingredients/"+ item_name +".png")


# Function to visibly show the player what they are on 
func update_slot_selected(show: bool):
	var slot = get_current_slot()
	var tint = slot.get_select_tint()
	if show:
		tint.show()
	else:
		tint.hide()

func select_ingredient():
	var slot = get_current_slot()
	slot.on_selected()

func get_current_slot():
	return gridCont.get_child(current_slot)

func move_forward():
	update_slot_selected(false)
	if current_slot + 1 > slots:
		return current_slot
	return current_slot + 1

func move_backward():
	update_slot_selected(false)
	if current_slot - 1 < 0:
		return current_slot
	return current_slot - 1

func move_up():
	update_slot_selected(false)
	if current_slot - 5 < 0:
		return current_slot
	return current_slot - 5

func move_down():
	update_slot_selected(false)
	if current_slot + 5 > slots:
		return current_slot
	return current_slot + 5
