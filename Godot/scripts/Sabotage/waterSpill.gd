extends Node3D

@export var duration: float = 10.0
@export var slow_down: float = 0.5		
@onready var reputation_system = ReputationSystem

var sabotaged_teamID: int
var teamID: int
var secs = 8.0

var water_particles: ParticleController
var players_in_spill : Array[Player] = []

signal in_water_spill()

# Set up the visual effects
# Taken from inflammable
func _setup_visual_effects():
	if water_particles:
		return # don't double-create
	water_particles = ParticleController.create_with_effect(ParticleController.EffectType.WATER_SPROUT)
	add_child(water_particles)
	water_particles.position = Vector3.ZERO  # local to this node
	water_particles.set_scale_multiplier(6.0)

# Start the effects of the waterSprout
func _start_water_effects() -> void:
	if water_particles:
		water_particles.play()

# Get the Sending team
func get_team(team_id: int) -> void:
	teamID = team_id

# Timer
func start_timer() -> void:
	var timer = Timer.new()
	timer.wait_time = secs
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	SabotageSystem.sabotage_start.emit(teamID, "Water Spill", secs)

# On the end of the time
func _on_timer_timeout() -> void:
	# Reset player speed
	for player in players_in_spill:
		player.set_speed(4)
	SabotageSystem.sabotage_ending.emit(teamID, "Water Spill")
	queue_free()

# Handle customer fall on server only to avoid duplicate effects
@rpc("any_peer", "call_remote", "reliable") 
func handle_customer_fall(customer_path: NodePath) -> void:
	var customer = get_node_or_null(customer_path)
	if not customer:
		return
		
	# 10% chance of falling
	var chance = randi() % 100
	print("Customer fall chance: ", chance)
	
	if chance < 100:  # 100% chance
		# sabotaged_teamID not assigned
		# Using modulo to get opposing side instead
		reputation_system.minus_reputation(teamID % 2 + 1, 5)
		
		# Notify all clients about the fall
		customer.fall_down()

# Notify all clients that customer fell
@rpc("authority", "call_local", "reliable")
func customer_falls(customer_path: NodePath) -> void:
	var customer = get_node_or_null(customer_path)
	if customer:
		handle_customer_fall(customer_path)

# Add the WaterSprout effect
func spill() -> bool:
	_setup_visual_effects()
	_start_water_effects()
	start_timer()
	return true

# Entering the waterSrpout
func _on_area_3d_body_entered(body:Node3D) -> void:
	print("Body entered water spill: ", body.name)

	if body is Player:
		# Player effects happen locally on each client
		body.drop_item(false)
		var water_team_id = get_team_id(body)
		reputation_system.minus_reputation(water_team_id, 2)
		players_in_spill.append(body)
		body.set_speed(1.5)
		emit_signal("in_water_spill")
		
	elif body is Customer:
		# Only handle customer fall on server to avoid duplicates
		if multiplayer.is_server():
			var customer_path = body.get_path()
			customer_falls(customer_path)
		
	else:
		print("Unknown body entered water: ", body)

# Get the player team ids
func get_team_id(body: Node3D) -> int:
	if ENetManager.get_team1().has(body.name.to_int()):
		return 1
	else:
		return 2

# Exiting the waterSpill
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		players_in_spill.erase(body)
		body.set_speed(4)
