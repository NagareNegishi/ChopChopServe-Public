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


func _ready() -> void:
	add_child(sync)
	
	var config : SceneReplicationConfig = SceneReplicationConfig.new()
	
	config.add_property(NodePath(".:team1_currency"))
	config.property_set_replication_mode(NodePath(".:team1_currency"),
	SceneReplicationConfig.REPLICATION_MODE_ON_CHANGE)
	
	config.add_property(NodePath(".:team2_currency"))
	config.property_set_replication_mode(NodePath(".:team2_currency"),
	SceneReplicationConfig.REPLICATION_MODE_ON_CHANGE)
	
	sync.replication_config = config
	sync.set_multiplayer_authority(1)
	
	
# Add more currency to the total
func add_currency(teamID: int, more_currency : float) -> void:
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
	
	rpc("_emit_singal", teamID, 
	team1_currency if teamID == 1 else team2_currency)


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
	
	return (team1_currency if teamID == 1 else team2_currency) + currency >= 0

@rpc("any_peer", "call_local")
func _emit_singal(teamID : int, currency : int):
	currency_changed.emit(teamID, currency)
