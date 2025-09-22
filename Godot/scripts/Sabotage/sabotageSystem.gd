#class_name Sabotage_System
extends Node

# Don't currently actually use
var current_sabotage

# Signals
signal sabotage_success(sabotage_type: int)
# Not used currently
signal sabotage_failed(reason: String)
signal sabotage_sending_team(teamID: int)

# Define Sabotage Types
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

# Get Globals
@onready var currency_system = CurrencySystem
@onready var reputation_system = ReputationSystem
@onready var global_script = GlobalScript

# ------------------- Requesting Sabotage Functions ------------------- #

# Clinets call this function
@rpc("any_peer", "call_local", "reliable")
# Request a Sabotage
func request_sabotage(teamID: int, sabotage_type: int) -> void:	
	print("teamID ::", teamID, "Resquesting sabotage of type: ", sabotage_type)

	# Only the server can process requests
	if not multiplayer.is_server():
		return
	# Get the sender ID for degbugging
	##var sender_id = multiplayer.get_remote_sender_id()
	##print("Clinet %s requests sabotage %s" % [sender_id, sabotage_type])
	
	# Get the cost of the sabotage
	var cost = sabotage_costs[sabotage_type]
	# Check if the team can afford it
	if not currency_system.check_currency(teamID, -cost):
		# Fix this !!
		##sabotage_failed.rpc_id(sender_id, "Not enough currency")
		print("Not going to work sorry")
		return

	# Pay the sabotage cost
	currency_system.minus_currency(teamID, cost)
	# Minus reputation : maybe delete?
	reputation_system.minus_reputation(teamID, 10)
	
	# If there is an extra peice of info needed for a sabotage
	# Get and pass it here
	# Probably a better way to do this !!

	# If FIRE, Get a flammable appliance path
	if sabotage_type == SabotageType.FIRE:
		var chosen_path = _pick_flammable_appliance_path()
		if chosen_path == NodePath(""):
			print("No flammable appliances available for fire sabotage")
			##sabotage_failed.rpc_id(sender_id, "No flammable appliances available")
			return
		# Call the execute Sabotage with a path
		execute_sabotage.rpc(teamID, sabotage_type, chosen_path)
	# If, WATER_SPILL, get a position
	elif sabotage_type == SabotageType.WATER_SPILL:
		var position = get_random_spill_position(teamID)
		# Call the execute Sabotage with position
		execute_sabotage_with_position.rpc(teamID, sabotage_type, position)
	else:
		# For now, otherwise just call the normal one
		execute_sabotage.rpc(teamID, sabotage_type, NodePath(""))

	# Broadcast sabotage to all clients
	execute_sabotage.rpc(teamID, sabotage_type)

# Server call this
@rpc("authority", "call_local", "reliable")
# Actually run the sabotage
# NORMAL + FIRE edition
func execute_sabotage(teamID: int, sabotage_type: int, chosen_path: NodePath) -> void:
	print("executing sabotage %s for team %s" % [sabotage_type, teamID])
	##current_sabotage = sabotage_type
	# Do the Sabotage with a path
	_do_sabotage(teamID, sabotage_type, chosen_path)
	# Signals
	sabotage_success.emit(sabotage_type)
	sabotage_sending_team.emit(teamID)

# Server call this
@rpc("authority", "call_local", "reliable")
# Actually run the sabotage
# WATER SPILL edition
func execute_sabotage_with_position(teamID: int, sabotage_type: int, position: Vector3) -> void:
	print("executing sabotage %s for team %s at position %s" % [sabotage_type, teamID, position])
	##current_sabotage = sabotage_type
	# Do the sabotage with a position
	_do_sabotage_with_position(teamID, sabotage_type, position)
	# Signals
	sabotage_success.emit(sabotage_type)
	sabotage_sending_team.emit(teamID)

# Enum getting for Sabotage Types
# WATER_SPILL edition
# Fix this up : could be done better?
func _do_sabotage_with_position(teamID: int, sabotage_type: int, position: Vector3) -> void:
	match sabotage_type:
		SabotageType.CRATE_SWITCH:
			print("crate stuff")
			# Handle crate switch sabotage

		# ------- Water Spill Stuff ------- #
		
		SabotageType.WATER_SPILL:
			print("water stuff")
			spawn_water_spill(teamID, 5.0, position)

		# ------- Water Spill Stuff ------- #
		SabotageType.FIRE:
			print("fire stuff")
			spawn_fire(teamID, _pick_flammable_appliance_path())
		SabotageType.FOOD_CRITIC:
			print("critic stuff")
			spawn_food_critic()
			# Handle food critic sabotage
		SabotageType.RAT_SWARM:
			print("rat stuff")
			# Handle rat swarm sabotage
		SabotageType.POWER_OUTAGE:
			print("power stuff")

	# Signals
	sabotage_success.emit(sabotage_type)
	sabotage_sending_team.emit(teamID)

# Enum getting for Sabotage Types
# NORMAL + FIRE edition
# Fix this up : could be done better?
func _do_sabotage(teamID: int, sabotage_type: int, chosen_path: NodePath) -> void:
	match sabotage_type:
		SabotageType.CRATE_SWITCH:
			print("crate stuff")
			# Handle crate switch sabotage
		SabotageType.WATER_SPILL:
			print("water stuff")
			#spawn_water_spill(teamID, 5.0, ) # duration can be adjusted

		# ------- Fire Start Stuff ------- #

		SabotageType.FIRE:
			print("fire stuff")
			spawn_fire(teamID, chosen_path)

		# ------- Fire Start Stuff ------- #
		SabotageType.FOOD_CRITIC:
			print("critic stuff")
			spawn_food_critic()
			# Handle food critic sabotage
		SabotageType.RAT_SWARM:
			print("rat stuff")
			# Handle rat swarm sabotage
		SabotageType.POWER_OUTAGE:
			print("power stuff")

	# Signals
	sabotage_success.emit(sabotage_type)
	sabotage_sending_team.emit(teamID)


# ------------------- Sabotage Functions ------------------- #

# ------- Crate Switch Stuff -------
# UNUSED CURRENTLY
func spawn_crate_switch() -> void:
	print("spawning crate switch")
	# findout whats happerning with the crate logic
	# should be similar to the critic logic
	# signal or call a function that does the switch
	# 

# ------- Water Spill Stuff -------
# Spawn a Water Spill
func spawn_water_spill(teamID: int, duration: float, position: Vector3) -> void:
	# TODO: Make sure position is vaild
	# I can Track who needs to lose Reputation
	print("spilling water")
	# Get the waterSpill.tscn : Change to the assest !!
	var spill = preload("res://scripts/Sabotage/waterSpill.tscn").instantiate()
	get_tree().get_current_scene().add_child(spill)
	# Get the position of the Spill
	spill.global_position = position
	##spill.global_position = get_random_spill_position(teamID)	
	spill.start_timer(duration)

# Helper Function
# Random position for the water spill
func get_random_spill_position(teamID: int) -> Vector3:

	# Currently this just spawns on the specific sides of the floor
	# Would like to so they don't spawn within appliances
	# It takes note of things 
	var floor_node = get_tree().get_current_scene().get_node("NavigationRegion3D/Floor")

	# Remove this later
	if not floor_node:
		push_error("Player node not found in scene!")
		return Vector3.ZERO
	else:
		print("found the player node")

	# Get the position
	var centre = floor_node.global_transform.origin
	
	# Offset Numbers
	var offset_x
	var offset_z

	# Is there a better way to do this ??
	if teamID == 1:
		offset_x = randf_range(-7, 9)
		offset_z = randf_range(-9, 0)
	elif teamID == 2:
		offset_x = randf_range(-7, 9)
		offset_z = randf_range(0, 9)

	# Return a position for the spill
	return centre + Vector3(offset_x, 0, offset_z)

# ------- Fire Stuff -------

# Spawn a Fire
func spawn_fire(teamID: int, chosen_path: NodePath) -> void:
	# TODO: Rework logic to work better (make waterSpill and fireStart the same)
	print("spawning fire")
	var fire_start = preload("res://scripts/Sabotage/fireStart.tscn").instantiate()
	get_tree().get_current_scene().add_child(fire_start)
	# Get all the familiable appliances
	fire_start.start_fire(teamID, chosen_path)

	# TODO: Look into finding a way to make the fire spread to the bench next door to them.

	#---------- OG code ----------#

	# Pick a random one
	# This should be changed to the one with the most progress
	# add a variable to check?
	##var random_index = randi() % flammable_appliances.size()
	#3var appliance = flammable_appliances[random_index]

	# Start the fire
	##if "inflammable_component" in appliance and appliance.inflammable_component:
	##	appliance.inflammable_component.ignite()
	##else:
	##	push_warning("Chosen appliance has no inflamiable compnent")

# Helper Function
# Ge the Random Flammable Appliance Path
func _pick_flammable_appliance_path() -> NodePath:
	print("picking a path")
	var flammables = get_tree().get_nodes_in_group("flammable")
	# If there is no flammables, then just send an empty path
	if flammables.size() == 0:
		print("no flammable appliances found")
		return NodePath("")

	# Find any appliances that are currently cooking
	var cooking := []
	for a in flammables:
		# If the Appliance is a powered and and cooking
		if a is PoweredAppliance and a.current_status == PoweredAppliance.Status.COOKING:
			# Add it
			cooking.append(a)

	# If there are none cooking, then just use the og list
	if cooking.size() == 0:
		cooking = flammables

	# Get a random appliance from the list
	var chosen = cooking[randi() % cooking.size()]
	print("chosen appliance: %s", % chosen)

	# Return the path of the appliance
	return chosen.get_path()

	# TODO: Add the fire spread logic etc:
	# Maybe put a timer here
	# start the timer and while the fire is going, then have it on
	# if the fire is stopped then stop the timer
	# but if the fire is still going when the timer ends
	# then spread the fire to another appliance

# ------- Food Critic Stuff -------
# UNUSED CURRENTLY
func spawn_food_critic() -> void:
	print("make a customer a critic")
	# Either:
		# send out a signal to make the next npc a critic
		# then deal with it in the npc script
	# Or:
		# create a function in the npc and call it here

# ------- Rat Swarm Stuff -------
# UNUSED CURRENTLY
func spawn_rat_swarm() -> void:
	print("spawning rat sparm")

# ------- Power Outage Stuff -------
# UNUSED CURRENTLY
func spawn_power_outage() -> void:
	print("spawning power outage")
