extends Node

@onready var sync : MultiplayerSynchronizer = MultiplayerSynchronizer.new()

# Starting CUrrency
# Change later - high for testing use
var team1_currency : int = 10000
var team2_currency : int = 10000

# Current starting currency is 200
# Change this back later !!
#@export var total_currency: float = 10000.0
signal currency_changed(teamID: int, new_currency: float)

	
	
# Add more currency to the total
func add_currency(teamID: int, more_currency : float) -> void:
	rpc("server_add_currency", teamID, more_currency)


@rpc("any_peer", "call_local", "reliable")
func server_add_currency(teamID: int, more_currency : float):
	if !ENetManager.is_host(): return;
	
	if !check_currency(teamID, more_currency):
		push_error("Not enough currency to add: %d" % more_currency)
		return
	
	if teamID == 1:
		team1_currency += more_currency
	elif teamID == 2:
		team2_currency += more_currency
	else:
		push_error("Invalid TeamID")
		return
	
	rpc("_client_add_currency", teamID, team1_currency if teamID == 1 else team2_currency)


# Minus currency from the total
func minus_currency(teamID, less_currency) -> void:
	# Make it a negitive number
	add_currency(teamID, -less_currency)


# Get the current total_currency
func get_currency(teamID: int) -> float:
	if teamID != 1 && teamID != 2: 
		push_error("Invalid TeamID")
		return -1
	
	return team1_currency if teamID == 1 else team2_currency


# Check that the new currency will still be above 0
func check_currency(teamID: int, currency: float) -> bool:
	if teamID != 1 && teamID != 2: 
		push_error("Invalid TeamID")
		return false
	
	return (team1_currency if teamID == 1 else team2_currency) - currency >= 0

@rpc("any_peer", "call_local")
func _client_add_currency(teamID : int, currency : int):
	if teamID == 1:
		team1_currency = currency
	elif teamID == 2:
		team2_currency = currency
	currency_changed.emit(teamID, currency)


# Check if team can afford a cost
func can_afford(teamID: int, cost: float) -> bool:
	return check_currency(teamID, -cost)
