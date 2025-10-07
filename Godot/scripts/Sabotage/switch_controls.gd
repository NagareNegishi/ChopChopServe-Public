extends Node3D

var secs = 3.0 # Change this
var player_ids := []

# Switching the players controls 
func switch_controls(teamID: int) -> void:
	if teamID == 1:
		player_ids = ENetManager.get_team2()
	else:
		player_ids = ENetManager.get_team1()

	for id in player_ids:
		var player = GlobalScript.get_local_player_by_id(id)
		player.invert_controls(true)
	start_timer(secs)

# Time for the switch
func start_timer(seconds: float) -> void:
	var timer = Timer.new()
	timer.wait_time = seconds
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

# End the Switch 
func _on_timer_timeout() -> void:
	for id in player_ids:
		var player = GlobalScript.get_local_player_by_id(id)
		if player:
			player.invert_controls(false)
			# Clean up the list
			player_ids.erase(id)
