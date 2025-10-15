extends Node

var total_rep_team = {
	0: 20.0,
	1: 20.0,
	2: 20.0
}

signal reputation_changed(teamID: int, new_reputation: float)

# Function to add to the total reputation
func add_reputation(teamID: int, amount: float) -> void:
	rpc("server_add_reputation", teamID, amount)

# Function to call to minus from the total_reputation
func minus_reputation(teamID: int, amount: float) -> void:
	# Send it to add but with a -
	add_reputation(teamID, -amount)

# Function to get the current reputation values
func get_reputation(teamID: int) -> float:
	return total_rep_team[teamID]


@rpc("any_peer", "call_local")
func _client_add_reputation(teamID: int, new_reputation: float):
	total_rep_team[teamID] = new_reputation
	reputation_changed.emit(teamID, new_reputation)


@rpc("any_peer", "call_local")
func server_add_reputation(teamID: int, amount: float) -> void:
	if !ENetManager.is_host(): return
	# Clamp the total_reputation between 0 and 100
	 
	rpc("_client_add_reputation", teamID, clamp(total_rep_team[teamID] + amount, 0, 100))
