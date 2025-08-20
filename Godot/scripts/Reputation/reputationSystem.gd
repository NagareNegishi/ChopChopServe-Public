extends Node

# Dictionary to hold each player's reutation
var player_reputations: Dictionary = {}

signal reputation_changed(peer_id: int, new_reputation: float)

# Initialise a player's reputation
func register_player(peer_id: int, starting_reputation: float = 20.0) -> void:
	player_reputations[peer_id] = clamp(starting_reputation, 0, 100)
	print("Player %d registered with reputation: %d" % [peer_id, player_reputations[peer_id]])

# add reputation to a specific player
func add_player_reputation(peer_id: int, amount: float) -> void:
	if peer_id in player_reputations:
		player_reputations[peer_id] = clamp(player_reputations[peer_id] + amount, 0, 100)
		print("Player %d reputation changed to: %f" % [peer_id, player_reputations[peer_id]])
		reputation_changed.emit(peer_id, player_reputations[peer_id])
		# Does the game end when they reach 100?

# Subtract reputation
func minus_reputation(peer_id: int, amount: float) -> void:
	add_player_reputation(peer_id, -amount)

# Get a player's current reputation
func get_player_reputation(peer_id: int) -> float:
	if peer_id in player_reputations:
		return player_reputations[peer_id]
	return 0.0 # Default if player not found