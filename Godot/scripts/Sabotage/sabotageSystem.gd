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

# Don't currently actually use
var current_sabotage

# Arrays for the sabotages
var on_fire := []
var benches := []

# Signals
signal sabotage_success(sabotage_type: int)
# Not used currently
signal sabotage_failed(reason: String)

signal sabotage_sending_team(teamID: int)

signal sabotage_ending(sab_name: String)
signal sabotage_start(sab_name: String, sab_time: int)

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

# Times of the sabotages
# Maybe make this a thing that is passed when calling?
const sabotage_times = [
	10, # Water Spill
	100, # Fire (forever)
	100, # Critic (forever)
	23, # Switch Player Controls
	20, # Rat Swarm
	15, # Power Outage
]

# Do I need to add an enum for the 'cost' of each sabotages reputation

# Get Globals
@onready var currency_system = CurrencySystem
@onready var reputation_system = ReputationSystem
@onready var global_script = GlobalScript
@onready var rat_attack = RatAttack
@onready var player = Player

func _ready() -> void:
	sabotage_ending.connect(on_sabotage_ending)
	sabotage_success.connect(on_sabotage_success)
	sabotage_failed.connect(_on_sabotage_failed)
	sabotage_start.connect(on_sabotage_start)

# ------------------- Requesting Sabotage Functions ------------------- #

# Clinets call this function
@rpc("any_peer", "call_local", "reliable")
# Request a Sabotage
func request_sabotage(teamID: int, sabotage_type: int) -> void:	
	print("teamID ::", teamID, "Resquesting sabotage of type: ", sabotage_type)

	# Only the server can process requests
	if not multiplayer.is_server():
		return

	# Get the cost of the sabotage
	var cost = sabotage_costs[sabotage_type]
	# Check if the team can afford it
	if not currency_system.check_currency(teamID, -cost):
		# Fix this !!
		##sabotage_failed.rpc_id(sender_id, "Not enough currency")
		# Change this to a UI error popup
		print("Not going to work sorry")
		return

	# Pay the sabotage cost
	currency_system.minus_currency(teamID, cost)

	# If FIRE, Get a flammable appliance path
	if sabotage_type == SabotageType.FIRE:
		var chosen_path = _pick_flammable_appliance_path(teamID)
		if chosen_path == NodePath(""):
			print("No flammable appliances available for fire sabotage")
			sabotage_failed.emit("No Famiable Appliances")
			return
		# Call the execute Sabotage with a path
		execute_sabotage.rpc(teamID, sabotage_type, chosen_path, Vector3(0, 0, 0))

	# If, WATER_SPILL, get a position
	elif sabotage_type == SabotageType.WATER_SPILL:
		var position = get_random_position(teamID)
		print("position of water is : ", position)
		# Call the execute Sabotage with position
		execute_sabotage.rpc(teamID, sabotage_type, NodePath(""), position)
	
	# If RAT_SPAWN
	elif sabotage_type == SabotageType.RAT_SWARM:
			var position = get_random_position(teamID)
			for i in range (5):
				var chosen_path = find_object_path()
				execute_sabotage.rpc(teamID, sabotage_type, chosen_path, position)
	else:
		# For now, otherwise just call the normal one with empty path and position
		execute_sabotage.rpc(teamID, sabotage_type, NodePath(""), Vector3(0, 0, 0))
		sabotage_ending.connect(on_sabotage_ending)

# ------------------- Execute Sabotage Function ------------------- #

# Call to run the Sabotages
# Server call this
@rpc("authority", "call_local", "reliable")
func execute_sabotage(teamID: int, sabotage_type: int, chosen_path: NodePath, position: Vector3 ) -> void:
	print("executing sabotage %s for team %s" % [sabotage_type, teamID])
	# Do the Sabotages
	_do_sabotage(teamID, sabotage_type, chosen_path, position)
	# Signals
	sabotage_success.emit(sabotage_type)
	sabotage_sending_team.emit(teamID)

# ------------------- Do Sabotage Function ------------------- #

# Enum getting for Sabotage Types to run
func _do_sabotage(teamID: int, sabotage_type: int, chosen_path: NodePath, position: Vector3) -> void:
	match sabotage_type:
		SabotageType.WATER_SPILL:
			print("water stuff")
			spawn_water_spill(teamID, position)
		SabotageType.FIRE:
			print("fire stuff")
			spawn_fire(teamID, chosen_path)
		SabotageType.FOOD_CRITIC:
			print("critic stuff")
			spawn_food_critic()
			# Handle food critic sabotage
		SabotageType.SWITCH_CONTROLS:
			print("switch stuff")
			spawn_switch_controls(teamID)
			# Handle switch controls sabotage
		SabotageType.RAT_SWARM:
			print("rat stuff")
			spawn_rat_swarm(position, chosen_path)
			# Handle rat swarm sabotage
		SabotageType.POWER_OUTAGE:
			print("power stuff")
			spawn_power_outage(teamID)

	# Signals
	sabotage_success.emit(sabotage_type)
	sabotage_sending_team.emit(teamID)


# ------------------- Implement Sabotage Functions ------------------- #

# ------- Water Spill Stuff ------- #

# Make sure the spills aren't over lapping eachother
var used_pos := []
const MIN_SPILL_DISTANCE := 1.5

func spawn_water_spill(teamID: int, position: Vector3) -> void:
	# Check if position is too close to any used position
	print("spilling water")
	var spill = preload("res://scripts/Sabotage/waterSpill.tscn").instantiate()
	get_tree().get_current_scene().add_child(spill)

	spill.global_position = position
	spill.set_sabotaged_team(teamID)
	spill.spill()
	
# Random position for the water spill
func get_random_position(teamID: int) -> Vector3:

	# Currently this just spawns on the specific sides of the floor
	# Would like to so they don't spawn within appliances
	var water_pos
	# Get the position
	var centre = Vector3.ZERO
	
	# Offset Numbers
	var offset_x
	var offset_z

	# Is there a better way to do this ??
	#if teamID == 1:
	#	offset_x = randf_range(-7, 9)
	#	offset_z = randf_range(-9, 0)
	#elif teamID == 2:
	#	offset_x = randf_range(-7, 9)
	#	offset_z = randf_range(0, 9)

	# New Range for the waterSpill position options
	# Check it is good for all levels !!
	if teamID == 1:
		offset_x = randf_range(-7, 11)
		offset_z = randf_range(-10, 2)
	elif teamID == 2:
		offset_x = randf_range(-7, 11)
		offset_z = randf_range(-2, 10)

	water_pos = centre + Vector3(offset_x, 0, offset_z)
	# Check it's not going to overlap another waterSpill
	for p in used_pos:
		if water_pos.distance_to(p) < MIN_SPILL_DISTANCE:
			if offset_x < 0 || offset_z < 0:
				water_pos = water_pos + Vector3(0.8, 0, 0.8)
			elif offset_x > 0 || offset_z > 0:
				water_pos = water_pos + Vector3(-0.8, 0, -0.8)

	used_pos.append(water_pos)

	return water_pos

# ------- Fire Stuff ------- #

# Spawn a Fire
func spawn_fire(teamID: int, chosen_path: NodePath) -> void:
	var fire_start = preload("res://scripts/Sabotage/fireStart.tscn").instantiate()
	get_tree().get_current_scene().add_child(fire_start)
	fire_start.fire_spread.connect(_on_fire_spread)
	fire_start.start_fire(teamID, chosen_path)

# Called when the fire spreads
func _on_fire_spread(teamID: int, prev_path: NodePath) -> void:
	if not multiplayer.is_server():
		return

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
		if a.get_appliance_owner() != teamID:
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
func spawn_rat_swarm(position: Vector3, path: NodePath) -> void:
	print("spawning rat sparm")
	RatAttack.spawn_rat_mischief(position, path)

# Find the path of a bench within the scene
func find_object_path() -> NodePath:
	var appliances = get_tree().get_nodes_in_group("flammable")
	# Check its not empty
	if appliances.size() == 0:
		print("no flammable appliances found")
		return NodePath("")
	# Get the benches
	for item in appliances:
		if item is Bench:
			benches.append(item)
	
	var b = benches[randi() % benches.size()]
	# Do I need to do this?
	# Aim is to make sure they are going to different benches each time
	benches.erase(b)
	return b.get_path()

# ------- Power Outage Stuff ------- #
func spawn_power_outage(teamID: int) -> void:
	var power = preload("res://scripts/Sabotage/powerOutage.tscn").instantiate()
	get_tree().get_current_scene().add_child(power)
	power.power_outage(teamID)


# ------------------- Signal Functions ------------------- #

# Sabotage Starting signal catcher
func on_sabotage_success(sab_type: int):
	# Here you would start the UI for the sabotage
	print("jess: the sabotage has started !! ", sab_type)

# Sabotage Failing signal catcher
func _on_sabotage_failed(reason: String):
	# Here you would make a pop up saying why the sabotage didn't work
	# and/ or redo an action but with information that will work
	print("jess: the sabotage failed !!\n the reason is because ", reason)

# Sabotage Ending signal catcher
func on_sabotage_ending(sabotage_name: String):
	# Here the UI would end etc
	print("jess: the sabotage ", sabotage_name, " has ended now !!")
	# Do something with the UI here

func on_sabotage_start(sabotage_name: String, sab_time: int):
	print("jess: I an going to start the ", sabotage_name, " for ", sab_time, " now")
