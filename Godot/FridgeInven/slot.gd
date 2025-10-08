extends Button
class_name Slot

signal food_requested(food_name: String)

@export var inventory_item_name: String = "Default"

@onready var item_text = $ColorRect/ColorRect/item_texture
@onready var select_tint = $SelectTint


func _ready():
	select_tint.hide()
	update_slot(true)

# This updates whether the slot should have the item available or whether you need to buy a restock
func update_slot(flag:bool):
	if flag:
		item_text.show()
	else:
		item_text.hide()


func assign_item_text(text: Texture2D):
	if item_text:
		item_text.texture = text


func _on_button_down():
	food_requested.emit(inventory_item_name)
	return inventory_item_name


func on_selected():
	food_requested.emit(inventory_item_name)
	return inventory_item_name

func get_select_tint():
	return select_tint
