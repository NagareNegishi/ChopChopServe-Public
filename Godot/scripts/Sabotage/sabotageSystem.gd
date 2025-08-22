#class_name Sabotage_System
extends Node

var current_sabotage

# Maybe add signals for this code so that others know whats up
signal sabotage_success(sabotage_type: int)
signal sabotage_failed(reason: String)

# Define sabotage cost money
# maybe add their time?
enum SabotageType {
	CRATE_SWITCH,
	WATER_SPILL,
	FIRE,
	FOOD_CRITIC,
	RAT_SWARM,
	POWER_OUTAGE
}

# Costs
const sabotage_costs = [	
	400, # Crate
	450, # Water
	600, # Fire
	700, # Critic
	900, # Rat
	1200 # Power
]

#var sabotage_costs = {
#"food_critic" : 700,
#	"rat_swarm" : 900,
#	"power_outage" : 1200,
#}

# Called to attempt a sabotage action
#@rpc("any_peer") # clients can request, server decides
#func request_sabotage(saboteur_id: int, target_id: int, sabotage_type: int) -> void:
# maybe change this to an emum working out
func request_sabotage(sabotage_type: int) -> void:	
	#if not multiplayer.is_server():
	#	return # only server can process
	print("Requesting sabotage of type: ", sabotage_type)
	var cost = sabotage_costs[sabotage_type]
	var currency_system = CurrencySystem
	var reputation_system = ReputationSystem

	# Check if saboteur can afford it
	#if not currency_system.check_currency(-cost):
	#	sabotage_failed.emit("Not enough currency")
	#	return
	print("got enough money")

	# pay the sabotage cost
	currency_system.minus_currency(cost)

	match sabotage_type:
		SabotageType.CRATE_SWITCH:
			print("crate stuff")
			# Handle crate switch sabotage
		SabotageType.WATER_SPILL:
			print("water stuff")
			spawn_water_spill(2.0) # duration can be adjusted
		SabotageType.FIRE:
			print("fire stuff")
			# Handle fire sabotage
		SabotageType.FOOD_CRITIC:
			print("critic stuff")
			# Handle food critic sabotage
		SabotageType.RAT_SWARM:
			print("rat stuff")
			# Handle rat swarm sabotage
		SabotageType.POWER_OUTAGE:
			print("power stuff")

	# Apply sabotage effect
	#match sabotage_type:
	##		print("crate stuff")
	#	"water_spill" :
	#		print("water stuff")
	#		spawn_water_spill(10.0) # duration can be adjuste
	#		print("water stuff")
	#	"fire":
	#		print("fire stuff")
	#	"food_critic":
	#		print("critic stuff")
	#	"rat_swarm":
	#		print("rat stuff")
	#	"power_outage":
	#		print("power stuff")
	
	print("got a type")
	# Notify everyone
	sabotage_success.emit(sabotage_type)

	# how you call this stuff:
	# $SabotageManager.request_sabotage.rpc(my_peer_id, target_peer_id, "steal_currency")

#func spawn_water_spill(target_id: int, duration: float) -> void:
func spawn_water_spill(duration: float) -> void:
	print("spilling water")
	var spill = preload("res://scripts/Sabotage/waterSpill.tscn").instantiate()
	get_tree().get_current_scene().add_child(spill)
	spill.global_position = get_random_spill_position()	
	spill.start_timer(duration)

func get_random_spill_position() -> Vector3:
	print("cehcing one two three")
	# Example: pick a random spot near the target
	var target_node = get_tree().get_current_scene().get_node("Player")
	if not target_node:
		push_error("Player node not found in scene!")
	return Vector3.ZERO
	var pos = target_node.global_transform.origin
	pos.x += randf() * 4 - 2  # random offset -2..2
	pos.z += randf() * 4 - 2
	return pos
