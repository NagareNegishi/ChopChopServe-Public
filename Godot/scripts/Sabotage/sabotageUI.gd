extends Control



func _on_water_button_pressed() -> void:
	$SabotageSystem.request_sabotage.rpc(my_peer_id, target_peer_id, "steal_currency")

