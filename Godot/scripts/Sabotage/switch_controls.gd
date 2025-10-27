extends Node3D

var secs = 10.0 # Change this
var player_ids := []
var teamID

# Switching the players controls 
func switch_controls(team_id: int) -> void:
	teamID = team_id
	# Get the players team
	if teamID == 1:
		player_ids = ENetManager.get_team2()
	else:
		player_ids = ENetManager.get_team1()
	# Get the players in that team
	for id in player_ids:
		var player = GlobalScript.get_local_player_by_id(id)
		# And invert their controls
		player.invert_controls(true)
	start_timer(secs)

# Timer for the switch
func start_timer(seconds: float) -> void:
	var timer = Timer.new()
	timer.wait_time = seconds
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	SabotageSystem.sabotage_start.emit(teamID, "Switch Controls", secs)

# End the Switch 
func _on_timer_timeout() -> void:
	# Go through the players
	for id in player_ids:
		var player = GlobalScript.get_local_player_by_id(id)
		if player:
			# And uninvert their controls
			player.invert_controls(false)
			# Clean up the list
			player_ids.erase(id)
			
	SabotageSystem.sabotage_ending.emit(teamID, "Switch Controls")
