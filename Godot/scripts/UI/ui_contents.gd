#@tool
class_name UIContents
extends Control

const MAX_AMOUNT : int = 3
const ADD_TEXTURE = preload("res://assets/textures/misc/add.png")

@export var content_amount : int = 0
var current_amount : int = 0

func _ready() -> void:
	var item = TextureRect.new()
	item.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	item.texture = ADD_TEXTURE
	$HBox.add_child(item)

func set_amount(amount : int):
	content_amount = clampi(amount, 0, MAX_AMOUNT)
	

func add_food(food : Food) -> bool:
	if current_amount + 1 > MAX_AMOUNT:
		clear()
		return false
	
	$HBox.get_child(current_amount).texture = (
		preload("res://assets/textures/ingredients/tomato.png") 
		if food == null || food.texture == null else food.texture)
	
	current_amount += 1
	
	if current_amount >= MAX_AMOUNT:
		return true
	
	var item = TextureRect.new()
	item.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	item.texture = ADD_TEXTURE
	$HBox.add_child(item)
		
	return true
	
func clear() -> void:
	
	current_amount = 0
	var first : bool = true
	
	for item in $HBox.get_children():
		if first:
			item.texture = ADD_TEXTURE
			first = false
		else:
			$HBox.remove_child(item)
			item.free()
