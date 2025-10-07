extends Control

@export var layer_depth: int = 100
@export var group : groups

var is_open: bool = false
@onready var gridCont = $GridContainer
@onready var subviewport = $".."
@onready var sprite = $"../.."

var SlotScene := preload("res://FridgeInven/slot.tscn")
var columns : int = 5
var slots : int = 5
var current_slot = 0

enum groups {
	groupOne,
	groupTwo,
	groupThree,
	groupFour
}

var g = {
	"groupOne" : ["chicken", "ham", "beef", "fish", "egg"],
	"groupTwo" : ["milk", "cheese", "flour", "dough", "pasta","cocoa"],
	"groupThree" : ["pineapple", "apple", "tomato", "pumpkin","strawberry"],
	"groupFour" : ["garlic", "mushroom", "onion", "potato"]
}


func _ready():
	gridCont.columns = columns
	sprite.position.y = 1
	print("\n\n",sprite.position.y)
	set_up_inven()
	close()


# Have these called by the fridge so it can open and close the inventory
func open():
	sprite.visible = true
	is_open = true

func close():
	sprite.visible = false
	is_open = false
	update_slot_selected(false)
	current_slot = 0


func set_up_inven():
	var selectedGroup = group
	var group_name = groups.keys()[selectedGroup]
	gridCont.columns = g[group_name].size()
	change_svp_size()
	for item in g[group_name]:
		add_slot(item)

# svp means subviewport
func change_svp_size():
	var temp_slot = SlotScene.instantiate()
	var width = 100
	var height = 100
	
	var subview_width = width * slots
	subviewport.size.x = subview_width
	subviewport.size.y = height

func add_slot(item_name: String):
	var slot_instance = SlotScene.instantiate()
	slot_instance.call_deferred("assign_item_text", get_2D_texture(item_name))
	slot_instance.inventory_item_name = item_name
	var food_factory = get_parent().get_parent().get_parent()
	if food_factory and food_factory is FoodFactory:
		slot_instance.food_requested.connect(food_factory._on_food_selected)
	else:
		print("ERROR: Could not find FoodFactory parent")
	
	gridCont.add_child(slot_instance)


func find_food_factory() -> FoodFactory:
	var current = self
	while current:
		if current is FoodFactory:
			return current
		current = current.get_parent()
	return null


func get_2D_texture(item_name: String) -> Texture2D:
	return load("res://assets/textures/ingredients/"+ item_name +".png")

# Function to visibly show the player what they are on 
func update_slot_selected(show: bool):
	print("THE BOOL IN UDS:    ", show)
	print("Current slot is:", current_slot)
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
	print("1")
	update_slot_selected(false)
	if current_slot + 1 > slots:
		return current_slot
	return current_slot + 1

func move_backward():
	print("2")
	update_slot_selected(false)
	if current_slot - 1 < 0:
		current_slot = current_slot
	return current_slot - 1
