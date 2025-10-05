extends Node3D

func switch_controls(teamID: int) -> void:
	var attack_id = ENetManager.get_my_id()
	print("jess: I am the attacker = ", attack_id)

	# Find target player by team, not hardcoded id
	var target_players = ENetManager.get_players_by_team(teamID)
	if target_players.is_empty():
		print("jess: no players found in team ", teamID)
		return

	# Example: just switch the first player found
	var player = target_players[0]
	if player == null:
		print("jess: player is null, can't switch controls")
		return

	player.invert_controls(true)
	print("jess: im switching your controls", player)
