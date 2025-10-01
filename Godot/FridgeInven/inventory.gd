extends Control

@export var layer_depth: int = 100

var is_open: bool = false
@onready var gridCont = $ColorRect/GridContainer

var SlotScene := preload("res://FridgeInven/slot.tscn")

var columns : int = 5
var slots : int = 20

func _ready():
	gridCont.columns = columns
	set_up_inven()
	close()

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
