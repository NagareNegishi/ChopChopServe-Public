extends Node

var total_rep_team = {
	1: 20.0,
	2: 20.0
}

signal reputation_changed(teamID: int, new_reputation: float)

# Function to add to the total reputation
func add_reputation(teamID: int, amount: float) -> void:
	# Clamp the total_reputation between 0 and 100
	total_rep_team[teamID] = clamp(total_rep_team[teamID] + amount, 0, 100)
	reputation_changed.emit(teamID, total_rep_team[teamID])

# Function to call to minus from the total_reputation
func minus_reputation(teamID: int, amount: float) -> void:
	# Send it to add but with a -
	add_reputation(teamID, -amount)

# Function to get the current reputation values
func get_reputation(teamID: int) -> float:
	return total_rep_team[teamID]
