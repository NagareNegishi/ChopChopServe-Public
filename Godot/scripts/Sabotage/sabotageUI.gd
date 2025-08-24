extends Control

# Water Spill Button
func _on_water_button_pressed() -> void:
	SabotageSystem.request_sabotage(1)
