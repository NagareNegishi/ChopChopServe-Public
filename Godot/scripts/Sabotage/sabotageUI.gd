extends Control



func _on_water_button_pressed() -> void:
	print("hello button pressed")
	#Sabotage_System.SabotageType.WATER_SPILL
	SabotageSystem.request_sabotage(1)
