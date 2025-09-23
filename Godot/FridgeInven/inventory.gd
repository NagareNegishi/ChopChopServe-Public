extends Control

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
	add_slot("beef", 5, 5)
	add_slot("cheese", 5, 5)
	add_slot("chicken", 5, 5)
	add_slot("cocoa", 5, 5)
	add_slot("dough", 5, 5)
	add_slot("egg", 5, 5)
	add_slot("fish", 5, 5)
	add_slot("flour", 5, 5)
	add_slot("garlic", 5, 5)
	add_slot("ham", 5, 5)
	add_slot("milk", 5, 5)
	add_slot("mushroom", 5, 5)
	add_slot("onion", 5, 5)
	add_slot("pasta", 5, 5)
	add_slot("pineapple", 5, 5)
	add_slot("potato", 5, 5)
	add_slot("pumpkin", 5, 5)
	add_slot("strawberry", 5, 5)

func add_slot(item_name: String, amount: int, price: int):
	var slot_instance = SlotScene.instantiate()
	slot_instance.call_deferred("assign_item_text", get_2D_texture(item_name))
	slot_instance.inventory_item_name = item_name
	slot_instance.amount = amount
	slot_instance.price = price
	
	gridCont.add_child(slot_instance)

func get_2D_texture(item_name: String) -> Texture2D:
	return load("res://assets/textures/ingredients/"+ item_name +".png")
