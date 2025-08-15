@tool
class_name UIContents
extends Control

signal edited

const MAX_AMOUNT : int = 3

@export var content_amount : int = 1 : set = set_amount
var current_amount : int = 0

func set_amount(amount : int):
	print("ahhhhhh")
	content_amount = clampi(amount, 1, MAX_AMOUNT)
	for i in range(content_amount):
		if i > content_amount - 1:
			$HBox.get_child(i).visible = false

func add_food(food : Food) -> bool:
	current_amount += 1
	$HBox.get_child(current_amount)
	return true
	
func clear() -> void:
	current_amount = 0
