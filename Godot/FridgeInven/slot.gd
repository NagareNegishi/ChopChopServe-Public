extends Button
class_name Slot

signal food_requested(food_name: String)

@export var inventory_item_name: String = "Default"

@onready var item_text = $ColorRect/ColorRect/item_texture
@onready var select_tint = $SelectTint

var AMOUNT

var need_to_buy: bool = false
var buy_texture : Texture2D

func _ready():
	select_tint.hide()
	update_slot(true)

# This updates whether the slot should have the item available or whether you need to buy a restock
func update_slot(flag:bool):
	if flag:
		need_to_buy = false
		item_text.show()
	else:
		need_to_buy = true
		item_text.hide()


func assign_item_text(text: Texture2D):
	if item_text:
		item_text.texture = text


func _on_button_down():
	if !need_to_buy:
			food_requested.emit(inventory_item_name)
			return inventory_item_name
	else:
		var team_id = ENetManager.get_my_team()
		update_slot(true)


func on_selected():
	if !need_to_buy:
			food_requested.emit(inventory_item_name)
			return inventory_item_name
	else:
		var team_id = ENetManager.get_my_team()
		update_slot(true)

func get_select_tint():
	return select_tint
