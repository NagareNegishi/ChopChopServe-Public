class_name PlayerCar
extends CharacterBody3D


@export var speed : float = 8
@export var turn_speed : float = 3
@export var acceleration : float = 10
@export var decceleration : float = 40
@export var camera_length : float = 7

var input_disable : bool = false
var turn_input : int
var move_input : int

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
	_clear_inputs()
	var lowest_input
	turn_input = 0
	move_input = 0
	
	if !player_inputs.is_empty():
		lowest_input = player_inputs.keys().reduce(func(a, b):
			return a if player_inputs[a].time < player_inputs[b].time else b)
		
		turn_input = player_inputs[lowest_input].turn
		move_input = player_inputs[lowest_input].move
		

	#rotates mesh
	if !input_disable:
		rotation.y += turn_input * turn_speed * delta
	
	if move_input || !input_disable: #handles logic if player is moving 
		var forward : Vector3 = -transform.basis.z.normalized()
		var target_speed: float = (speed if move_input == 1 else speed/2) * move_input
		var target_velo: Vector3 = forward * target_speed
		
		velocity = velocity.move_toward(target_velo, acceleration * delta)
	else: #declerates player if not moving 
		velocity = velocity.move_toward(Vector3.ZERO, decceleration * delta)
	
	
	move_and_slide()

# Uses unactive particles from pool and actives them if player is moving
# @return void
@rpc("authority")
func _on_particle_timer_timeout() -> void:
	if (velocity == Vector3.ZERO || move_input == -1) && turn_input == 0:
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
		if now - player_inputs[key].time > 200:
			player_inputs.erase(key)

# adds input into player_input
func _on_received_input(peer_id: int, move : int, turn : int):
	player_inputs[peer_id] = {
		"move" : move,
		"turn" : turn,
		"time" : Time.get_ticks_msec()
	}
	print(player_inputs)
func disable_input(disable : bool):
	input_disable = disable
