extends Sprite3D

@onready var inventory = $SubViewport/Inventory
var press_time := 0.0

func _input(event):
	if inventory.is_open:
		if event.is_action_pressed("Action"):
			press_time = Time.get_ticks_msec() / 1000.0
		if event.is_action_released("Action"):
			var release_time = Time.get_ticks_msec() / 1000.0
			var held_duration = release_time - press_time
			
			if held_duration>= 0.5:
				inventory.select_ingredient()
			else:
				inventory.current_slot = inventory.move_forward()
		if event.is_action_pressed("Dash"):
			inventory.current_slot = inventory.move_backward()
		
		inventory.update_slot_selected(true)
