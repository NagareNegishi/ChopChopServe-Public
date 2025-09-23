extends Button
class_name Slot

@export var inventory_item_name: String = "Default"
@export var amount: int = 5
@export var price: int = 5

@onready var item_text = $ColorRect/ColorRect/item_texture
@onready var buy_text = $ColorRect/ColorRect/buy_texture

var AMOUNT

var need_to_buy: bool = false
var buy_texture : Texture2D

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	item_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	buy_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AMOUNT = amount
	update_slot(true)

func _process(delta):
	if amount <= 0:
		update_slot(false)

# This updates whether the slot should have the item available or whether you need to buy a restock
func update_slot(flag:bool):
	
	if flag:
		need_to_buy = false
		buy_text.hide()
		item_text.show()
	else:
		need_to_buy = true
		buy_text.show()
		item_text.hide()


func assign_item_text(text: Texture2D):
	if item_text:
		item_text.texture = text


func _on_button_down():
	if !need_to_buy:
			amount = amount - 1
			return inventory_item_name
	else:
		var team_id = ENetManager.get_my_team()
		CurrencySystem.minus_currency(team_id, price)
		amount = AMOUNT
		update_slot(true)
