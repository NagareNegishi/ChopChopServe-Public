extends Node

# Dictionary to hold each player's currency
var player_currency: Dictionary = {}

# @export var total_currency: float = 200.0
signal currency_changed(peer_id: int, new_currency: float)

# Regester a player whe they join
func register_player(peer_id: int, starting_currency: float = 200.0) -> void:
	player_currency[peer_id] = max(starting_currency, 0)
	print("Player %d registered with currency: %f" % [peer_id, player_currency[peer_id]])

# Add more currency to the total
func add_currency(peer_id: int, amount: float) -> void:
	if peer_id in player_currency and check_currency(peer_id, amount):
		print("Player %d adding currency: %f" % [peer_id, amount])
		player_currency[peer_id] += amount
		currency_changed.emit(peer_id, player_currency[peer_id])
	else:
		print("Player %d does not have enough currency to add %f" % [peer_id, amount])

   
# Minus currency from the total
func minus_currency(peer_id: int, amount: float) -> void:
    # Make it a negitive number
	add_currency(peer_id, -amount)

# Get the current total_currency
func get_currency(peer_id: int) -> float:
	if peer_id in player_currency:
		return player_currency[peer_id]
	return 0.0  # Default if player not found

# Check that the new currency will still be above 0
func check_currency(peer_id: int, amount: float) -> bool:
	if peer_id in player_currency:
		return player_currency[peer_id] + amount >= 0
	return false