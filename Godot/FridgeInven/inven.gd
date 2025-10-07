extends Sprite3D

@onready var inventory = $SubViewport/Inventory

func _input(event):
	if inventory.is_open:
		if event.is_action_pressed("Throw"):
			print("throw")
			inventory.current_slot = inventory.move_forward()
		if event.is_action_pressed("Dash"):
			print("dash")
			inventory.current_slot = inventory.move_backward()
		
		if event.is_action_pressed("Interact"):
			inventory.select_ingredient()
		
		inventory.update_slot_selected(true)
