class_name Sabotage_System
extends Node

################################################################################
# TODO:
	# - Clean code up
	# - Make sure everything is connected
	# - Make sure it's networking properly (fire)
	# - Change the get_random_position() function
	# - Do something with the signals
	# - Do I really need teamID?

	# - Should I remove teamID and make it that is the sabotaged team?
# Questions:
	# - How many of Each thing do we want?
		# - Water Spill
		# - Rats
	# - How long should each thing last?
	# - Do we want to be able to stack sabotages?
	# - Do we want to be able to have multiple sabotages of the same type at once?
################################################################################

# Add a general reputation loss function in here cause atm i don't see rep going down much

# Don't currently actually use both of these !!
var current_sabotage
var sab_team_id

# Arrays for the sabotages
var on_fire := []
var assigned_benches := []

# Signals
# Not used currently
signal sabotage_failed(reason: String)
# Are using these ones
signal sabotage_success(sabotage_type: int)
signal sabotage_sending_team(teamID: int)
signal sabotage_start(teamID: int, sab_name: String, sab_time: int)
signal sabotage_ending(teamID: int, sab_name: String)

# Define Sabotage Types
enum SabotageType {
	WATER_SPILL,
	FIRE,
	FOOD_CRITIC,
	SWITCH_CONTROLS,
	RAT_SWARM,
	POWER_OUTAGE
}

# Costs of the sabotages
const sabotage_costs = [	
	450, # Water Spill
	600, # Fire
	700, # Critic
	800, # Switch Player Controls
	900, # Rat Swarm
	1200 # Power Outage
]

# Get Globals
@onready var currency_system = CurrencySystem # Use
@onready var reputation_system = ReputationSystem # Don't Use
@onready var global_script = GlobalScript # Use once
@onready var rat_attack = RatAttack # Use once
@onready var player = Player # Don't use : do I need it ??
@onready var rat_manager = RatManager # Used twice

func _ready() -> void:
	# Might not need these anymore ...
	sabotage_ending.connect(on_sabotage_ending)
	sabotage_success.connect(on_sabotage_success)
	sabotage_failed.connect(_on_sabotage_failed)
	sabotage_start.connect(on_sabotage_start)

# ------------------- Requesting Sabotage Functions ------------------- #

# Clinets call this function
@rpc("any_peer", "call_local", "reliable")
# Request a Sabotage
func request_sabotage(teamID: int, sabotage_type: int) -> void:	
	# Only the server can process requests
	if not multiplayer.is_server():
		return
	# Get the cost of the sabotage
	var cost = sabotage_costs[sabotage_type]
	# Check if the team can afford it
	if not currency_system.check_currency(teamID, -cost):
		# Fix this !!
		##sabotage_failed.rpc_id(sender_id, "Not enough currency")
		# -------------------------------------- -------------------------------------------------------------------------------
		# Change this to a UI error popup !!!
		print("Not going to work sorry")
		return

	# Pay the sabotage cost
	currency_system.minus_currency(teamID, cost)
	# Minus Reputation for the other team
	# Using modulo to get opposing side instead
	reputation_system.minus_reputation(teamID % 2 + 1, 10)
	 
	# If FIRE, Get a flammable appliance path
	if sabotage_type == SabotageType.FIRE:
		var chosen_path = _pick_flammable_appliance_path(teamID)
		# This should never happen, but just in case
		if chosen_path == NodePath(""):
			print("No flammable appliances available for fire sabotage")
			sabotage_failed.emit("No Famiable Appliances")
			return
		# Call the execute Sabotage with an appliance path
		execute_sabotage.rpc(teamID, sabotage_type, chosen_path, Vector3(0, 0, 0))

	# If, WATER_SPILL, get a position
	elif sabotage_type == SabotageType.WATER_SPILL:
		var position = get_offset(teamID)
		print("position of water is : ", position)
		# Call the execute Sabotage with position
		execute_sabotage.rpc(teamID, sabotage_type, NodePath(""), position)
	
	# If RAT_SPAWN
	elif sabotage_type == SabotageType.RAT_SWARM:
		var position = get_random_position(teamID)
		# Start the rat timer here so theres only on
		rat_manager.testing_rat_timer()
		rat_manager.set_team_id(teamID)
		# Create upto five rats 
		for i in range(5):
			# Find Food on Benches
			var chosen_path = find_object_path(teamID)
			
			# ADD THIS CHECK - Don't spawn rat if no valid path found
			if chosen_path == NodePath(""):
				print("No valid bench found for rat #", i)
				continue  # Skip this rat
				
			# Call the Sabotage with a path and position
			execute_sabotage.rpc(teamID, sabotage_type, chosen_path, position)
		
	else:
		# The rest can just be called with an empty path and position			
		execute_sabotage.rpc(teamID, sabotage_type, NodePath(""), Vector3(0, 0, 0))

# ------------------- Execute Sabotage Function ------------------- #

# Call to run the Sabotages
# Server call this
@rpc("authority", "call_local", "reliable")
func execute_sabotage(teamID: int, sabotage_type: int, chosen_path: NodePath, position: Vector3 ) -> void:
	# Do the Sabotages
	_do_sabotage(teamID, sabotage_type, chosen_path, position)
	# Signals
	#sabotage_success.emit(sabotage_type)
	#sabotage_sending_team.emit(teamID)

# ------------------- Do Sabotage Function ------------------- #

# Enum getting for Sabotage Types to run
func _do_sabotage(teamID: int, sabotage_type: int, chosen_path: NodePath, position: Vector3) -> void:
	match sabotage_type:
		# Handle waterSpill sabotage
		SabotageType.WATER_SPILL:
			print("water stuff")
			spawn_water_spill(teamID, position)
		# Handle fire sabotage
		SabotageType.FIRE:
			print("fire stuff")
			spawn_fire(teamID, chosen_path)
		# Handle foodCritic sabotage
		SabotageType.FOOD_CRITIC:
			print("critic stuff")
			spawn_food_critic()
		# Handle switchControls sabotage
		SabotageType.SWITCH_CONTROLS:
			print("switch stuff")
			spawn_switch_controls(teamID)
		# Handle ratSwarm sabotage
		SabotageType.RAT_SWARM:
			print("rat stuff")
			spawn_rat_swarm(teamID, position, chosen_path)
		# Handle powerOutage sabotage
		SabotageType.POWER_OUTAGE:
			print("power stuff")
			spawn_power_outage(teamID)

	# Signals
	# Do I need something here ?
	#sabotage_success.emit(sabotage_type)
	#sabotage_sending_team.emit(teamID)


# ------------------- Implement Sabotage Functions ------------------- #

# ------- Water Spill Stuff ------- #

# Make sure the spills aren't over lapping eachother
var used_pos := []
var MIN_SPILL_DISTANCE := 1.5

func spawn_water_spill(teamID: int, position: Vector3) -> void:
	print("spilling water")
	# get the spill and add it to the scene
	var spill = preload("res://scripts/Sabotage/waterSpill.tscn").instantiate()
	get_tree().get_current_scene().add_child(spill)
	# Get the position and team
	spill.global_position = position
	spill.get_team(teamID)
	spill.spill()


# Get a position for the waterSpill
func get_offset(teamID: int) -> Vector3:
	
	var offset_x = randf_range(-2, 2)
	var offset_z = randf_range(-2, 2)
	var water_pos
	var players:= []
	var player_ids := []

	# Get the sabotaged team
	if teamID == 1:
		player_ids = ENetManager.get_team2()
	else:
		player_ids = ENetManager.get_team1()

	# Get the Players in the sabotaged team
	for id in player_ids:
		players.append(global_script.get_local_player_by_id(id))
	
	for p in players:
		# Get the players positions
		var player_pos = p.global_transform.origin
		# Make the waterSpill 
		water_pos = player_pos + Vector3(offset_x, -player_pos.y, offset_z)

		# Making sure the waterSpill isn't going in the same positions
		# / Overlapping eachother
		for pos in used_pos:
			if water_pos.distance_to(pos) < MIN_SPILL_DISTANCE:
				# If it is: move it slightly
				if offset_x < 0 || offset_z < 0:
					water_pos = water_pos + Vector3(0.8, 0, 0.8)
				elif offset_x > 0 || offset_z > 0:
					water_pos = water_pos + Vector3(-0.8, 0, -0.8)

		used_pos.append(water_pos)
		#return water_pos

	return water_pos

# ------- Fire Stuff ------- #

# Spawn a Fire
func spawn_fire(teamID: int, chosen_path: NodePath) -> void:
	var fire_start = preload("res://scripts/Sabotage/fireStart.tscn").instantiate()
	get_tree().get_current_scene().add_child(fire_start)
	# Allow for a fire Spread
	fire_start.fire_spread.connect(_on_fire_spread)
	fire_start.start_fire(teamID, chosen_path)

# Called when the fire spreads
func _on_fire_spread(teamID: int, prev_path: NodePath) -> void:
	if not multiplayer.is_server():
		return
	# Using modulo to get opposing side
	# Making the team lose rep it the fire spreads
	reputation_system.minus_reputation(teamID % 2 + 1, 2)

	var new_path = _pick_flammable_appliance_path(teamID)
	if new_path != prev_path and new_path != NodePath(""):
		# Tell everyone to spawn the fire in the same place
		_rpc_spawn_fire.rpc(teamID, new_path)

# Spread fire for all clients and the server
@rpc("authority", "call_local", "reliable")
func _rpc_spawn_fire(teamID: int, chosen_path: NodePath) -> void:
	spawn_fire(teamID, chosen_path)

# Ge the Random Flammable Appliance Path
func _pick_flammable_appliance_path(teamID: int) -> NodePath:
	# Get the fammable appliances
	var flammables = get_tree().get_nodes_in_group("flammable")
	# There should always be appliances, but...
	if flammables.size() == 0:
		print("no flammable appliances found")
		return NodePath("")
	
	# Arrays for the Appliances
	var cooking := []
	var wrong_appliances := []

	# Filter them so that you've got the ones for the other team
	# And the Ones that are cooking
	for a in flammables:
		# There might be a better way to do this cleaner
		if a.get_appliance_owner() == teamID:
			wrong_appliances.append(a)
		elif a is PoweredAppliance and a.current_status == PoweredAppliance.Status.COOKING:
			cooking.append(a)
	# Remove the wrong appliances from the flammables
	for apps in wrong_appliances:
		flammables.erase(apps)
	# If there is nothing cooking, just go with any flammable
	if cooking.size() == 0:
		cooking = flammables
	var available := []
	for a in cooking:
		if not on_fire.has(a):
			available.append(a)
	if available.size() == 0:
		print("no available appliances found !!")
		# Maybe this is where we would want to force stop the day
		# and make the other team win
		return NodePath("")
	# Get a random appliance from the available ones
	var chosen_appliance = available[randi() % available.size()]
	on_fire.append(chosen_appliance)

	# Return the chosen appliance path
	return chosen_appliance.get_path()

# ------- Food Critic Stuff ------- #
# UNUSED CURRENTLY
func spawn_food_critic() -> void:
	print("make a customer a critic")
	# Either:
		# send out a signal to make the next npc a critic
		# then deal with it in the npc script
	# Or:
		# create a function in the npc and call it here

# ------- Switch Controls ------- #	
# Switch the Direction of the other teams controls
func spawn_switch_controls(teamID: int) -> void:
	print("switching controls")
	
	var controls = preload("res://scripts/Sabotage/switchControls.tscn").instantiate()
	get_tree().get_current_scene().add_child(controls)
	controls.switch_controls(teamID)

# ------- Rat Swarm Stuff ------- #
func spawn_rat_swarm(teamID: int, position: Vector3, path: NodePath) -> void:
	print("spawning rat sparm")
	rat_attack.spawn_rat_mischief(teamID, position, path)

# Find the path of a bench within the scene
func find_object_path(teamID: int) -> NodePath:
	var appliances = get_tree().get_nodes_in_group("flammable")
	# Check its not empty
	if appliances.size() == 0:
		print("no flammable appliances found")
		return NodePath("")

	var available_benches := []

	# Get the benches
	for item in appliances:
		# If they are for the other team
		if item.get_appliance_owner() != teamID:
			# If it is a bench with food on it
			if item is Bench:
				if item.contents.size() > 0 and not assigned_benches.has(item):
					available_benches.append(item)
	
	if available_benches.size() == 0:
		print("no available benches")
		return NodePath("")

	var b = available_benches[randi() % available_benches.size()]
	assigned_benches.append(b)

	return b.get_path()

# Random position for the rats
func get_random_position(teamID: int) -> Vector3:

	var target_pos
	# Spawn on different sides of the kitchen depending on what team 
	if teamID == 1:
		target_pos = Vector3(-5.7, -0.3, -8.6)
	elif teamID == 2:
		target_pos = Vector3(-5.7, -0.3, 8.6)

	return target_pos

# ------- Power Outage Stuff ------- #
func spawn_power_outage(teamID: int) -> void:
	var power = preload("res://scripts/Sabotage/powerOutage.tscn").instantiate()
	get_tree().get_current_scene().add_child(power)
	power.power_outage(teamID)

# ------------------- Signal Functions ------------------- #

# Don't actually use but still good to have
	
# Sabotage Starting signal catcher
func on_sabotage_success(sab_type: int):
	# Here you would start the UI for the sabotage
	pass
	#print("jess: the sabotage has started !! ", sab_type)

# Sabotage Failing signal catcher
func _on_sabotage_failed(reason: String):
	# Here you would make a pop up saying why the sabotage didn't work
	# and/ or redo an action but with information that will work
	pass
	#print("jess: the sabotage failed !!\n the reason is because ", reason)

# Sabotage Ending signal catcher
func on_sabotage_ending(sabotage_team: int, sabotage_name: String):
	# Here the UI would end etc
	pass
	#print("jess: the sabotage ", sabotage_name, " has ended now !!")
	# Do something with the UI here

func on_sabotage_start(sabotage_team: int, sabotage_name: String, sab_time: int):
	#print("jess: I an going to start the ", sabotage_name, " for ", sab_time, " now")
	pass