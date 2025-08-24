#class_name Sabotage_System
extends Node

var current_sabotage

# Signals
signal sabotage_success(sabotage_type: int)
signal sabotage_failed(reason: String)

# Define sabotage cost money
enum SabotageType {
	CRATE_SWITCH,
	WATER_SPILL,
	FIRE,
	FOOD_CRITIC,
	RAT_SWARM,
	POWER_OUTAGE
}

# Costs of the sabotages
const sabotage_costs = [	
	400, # Crate Switch
	450, # Water Spill
	600, # Fire
	700, # Critic
	900, # Rat Swarm
	1200 # Power Outage
]

# Request a sabotage
func request_sabotage(sabotage_type: int) -> void:	
	# print("Requesting sabotage of type: ", sabotage_type)
	var cost = sabotage_costs[sabotage_type]
	var currency_system = CurrencySystem
	var reputation_system = ReputationSystem

	# Check if saboteur can afford it
	if not currency_system.check_currency(-cost):
		sabotage_failed.emit("Not enough currency")
		return

	# pay the sabotage cost
	currency_system.minus_currency(cost)

	match sabotage_type:
		SabotageType.CRATE_SWITCH:
			print("crate stuff")
			# Handle crate switch sabotage
		SabotageType.WATER_SPILL:
			print("water stuff")
			spawn_water_spill(5.0) # duration can be adjusted
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

	# Notify everyone
	sabotage_success.emit(sabotage_type)

# Spawn a Water Spill
func spawn_water_spill(duration: float) -> void:
	print("spilling water")
	var spill = preload("res://scripts/Sabotage/waterSpill.tscn").instantiate()
	get_tree().get_current_scene().add_child(spill)
	spill.global_position = get_random_spill_position()	
	spill.start_timer(duration)

# Random position for the water spill
func get_random_spill_position() -> Vector3:
	# Example: pick a random spot near the target
	# Change this later for a wider range
	var target_node = get_tree().get_current_scene().get_node("Player")
	# Remove this later
	if not target_node:
		push_error("Player node not found in scene!")
		return Vector3.ZERO
	var pos = target_node.global_transform.origin
	pos.x += randf() * 4 #- 2
	pos.z += randf() * 4 #- 2
	return pos
