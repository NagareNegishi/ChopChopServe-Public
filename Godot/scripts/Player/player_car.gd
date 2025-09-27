class_name PlayerCar
extends CharacterBody3D


@export var speed : float = 8
@export var turn_speed : float = 3
@export var acceleration : float = 10
@export var decceleration : float = 40
@export var camera_length : float = 7

var turn_input_avg : int = 0
var move_input_avg : int = 0
var input_disable : bool = false

@onready var controller : PlayerCarController = $Controller
@onready var camera : Camera3D = $SpringArm/Camera


var move_particle = preload("res://Particles/MoveParticles.tscn")
var MOVE_PARTICLES_POOL = []

var  player_inputs = {}

## Called when the node enters the scene tree for the first time.
## @return void
func _ready() -> void:
	for i in range(10):
		var particle = move_particle.instantiate()
		MOVE_PARTICLES_POOL.append(particle)
	$SpringArm.spring_length = camera_length
	set_multiplayer_authority(1)
# Runs every process frame
# @param delta time to proces frame
# @return void
func _process(delta: float) -> void:
	if !ENetManager.is_host():
		$ParticleTimer.stop()
		return
	
	_movement(delta)
	_clear_inputs()
	
	if !is_on_floor():
		velocity += get_gravity() * delta
	

# Handles the movement logic for the car
# @param delta time to proces frame
# @return void
func _movement(delta : float) -> void:
	#resets average
	turn_input_avg = 0
	move_input_avg = 0
	
	var move_zero_count = 0
	var turn_zero_count = 0
	
	#adds all turn and move inputs
	for key in player_inputs.keys():
		turn_input_avg += player_inputs[key].turn
		move_input_avg += player_inputs[key].move
		
		#tracks how many players arent requesting to move
		if player_inputs[key].move == 0:
			move_zero_count += 1
		
		#tracks how many players arent requesting to turn
		if player_inputs[key].turn == 0:
			turn_zero_count += 1
	
	#averages inputs if at least one player is requesting to move
	if (player_inputs.size() - move_zero_count) != 0:
		turn_input_avg /= (player_inputs.size() - move_zero_count)
	
	#averages inputs if at least one player is requesting to turn
	if (player_inputs.size() - turn_zero_count) != 0:
		move_input_avg /= (player_inputs.size() - turn_zero_count)
	
	#clamps average bewteen -1 and 1
	turn_input_avg = clampi(turn_input_avg, -1, 1)
	move_input_avg = clampi(move_input_avg, -1, 1)

	#rotates mesh
	if !input_disable:
		rotation.y += turn_input_avg * turn_speed * delta
	
	if move_input_avg && !input_disable: #handles logic if player is moving 
		var forward : Vector3 = -transform.basis.z.normalized()
		var target_speed: float = (speed if move_input_avg == 1 else speed/2) * move_input_avg
		var target_velo: Vector3 = forward * target_speed
		
		velocity = velocity.move_toward(target_velo, acceleration * delta)
	else: #declerates player if not moving 
		velocity = velocity.move_toward(Vector3.ZERO, decceleration * delta)
	
	
	move_and_slide()

# Uses unactive particles from pool and actives them if player is moving
# @return void
@rpc("authority")
func _on_particle_timer_timeout() -> void:
	if (velocity == Vector3.ZERO || move_input_avg == -1) && turn_input_avg == 0:
		return
	
	var particle_index : int = -1

	for particle : MoveParticles in MOVE_PARTICLES_POOL:
		if !particle.is_active:
			particle_index = MOVE_PARTICLES_POOL.find(particle)
			break

	if particle_index == -1:
		return
	
	rpc("_spawn_particle", particle_index)


@rpc("authority", "call_local")
func _spawn_particle(index : int) -> void:
	var particle = MOVE_PARTICLES_POOL.get(index)
	particle.set_active(true)
	
	if particle.get_parent() != get_tree().get_current_scene():
		get_tree().get_current_scene().add_child(particle)

	particle.global_transform = $Mesh/ParticleSpawn.global_transform
	
# clears inputs stored in player_inputs if 
# they are pressed within given timeframe
# @return void 
func _clear_inputs():
	var now = Time.get_ticks_msec()
	for key in player_inputs.keys():
		if now - player_inputs[key].time > 300:
			player_inputs.erase(key)

# adds input into player_input
func _on_received_input(peer_id: int, move : int, turn : int):
	player_inputs[peer_id] = {
		"move" : move,
		"turn" : turn,
		"time" : Time.get_ticks_msec()
	}

func disable_input(disable : bool):
	input_disable = disable
