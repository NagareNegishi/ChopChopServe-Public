extends Node

var current_sabotage

# Maybe add signals for this code so that others know whats up
signal sabotage_success(saboteur_id: int, target_id: int, sabotage_type: int)
signal sabotage_failed(saboteur_id: int, reason: String)

# Define sabotage cost money
# maybe add their time?
var sabotage_costs = {
	"crate_switch" : 400,
	"water_spill" : 450,
	"fire" : 600,
	"food_critic" : 700,
	"rat_swarm" : 900,
	"power_outage" : 1200,
}

# Called to attempt a sabotage action
@rpc("any_peer") # clients can request, server decides
func request_sabotage(saboteur_id: int, target_id: int, sabotage_type: int) -> void:
	if not multiplayer.is_server():
		return # only server can process
	
	var cost = sabotage_costs[sabotage_type]
	var currency_system = $CurrencySystem
	var reputation_system = $ReputationSystem

	# Check if saboteur can afford it
	if not currency_system.check_currency(saboteur_id, -cost):
		sabotage_failed.emit(saboteur_id, "Not enough currency")
		return

	# pay the sabotage cost
	currency_system.minus_currency(saboteur_id, cost)

	# Apply sabotage effect
	match sabotage_type:
		"crate_switch":
			print("crate stuff")
		"water_spill" :
			print("water stuff")
		"fire":
			print("fire stuff")
		"food_critic":
			print("critic stuff")
		"rat_swarm":
			print("rat stuff")
		"power_outage":
			print("power stuff")
	
	# Notify everyone
	sabotage_success.emit(saboteur_id, target_id, sabotage_type)

	# how you call this stuff:
	# $SabotageManager.request_sabotage.rpc(my_peer_id, target_peer_id, "steal_currency")