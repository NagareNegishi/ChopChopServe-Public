class_name PlayerCar
extends CharacterBody3D


@export var speed : float = 8
@export var turn_speed : float = 3
@export var acceleration : float = 10
@export var decceleration : float = 7.5
@export var camera_length : float = 7

var input_disable : bool = false
var turn_input_avg : int = 0
var move_input_avg : int = 0

@onready var controller : PlayerCarController = $Controller
@onready var camera : Camera3D = $SpringArm/Camera

var move_particle = preload("res://Particles/MoveParticles.tscn")
var MOVE_PARTICLES_POOL = []

var player_inputs := {}
var time_start : int = 0
var client_offset : int = 0
## Called when the node enters the scene tree for the first time.
## @return void
func _ready() -> void:
	for i in range(10):
		var particle = move_particle.instantiate()
		MOVE_PARTICLES_POOL.append(particle)
	$SpringArm.spring_length = camera_length
	#set_multiplayer_authority(1)
	
	if !ENetManager.is_host(): 
		$ParticleTimer.stop()
		return
	
	time_start = Time.get_ticks_msec()
	rpc("_set_time_now", time_start)


@rpc("any_peer", "call_local")
func _set_time_now(cur : int):
	var local_now = Time.get_ticks_msec()
	client_offset = cur - local_now
	time_start = cur
	


## Runs every process frame
## @param delta time to proces frame
## @return void
func _process(delta: float) -> void:
	if Input.get_connected_joypads().size() <= 0:
		_keyboard_movement(delta)
	else:
		_controller_movement(delta)
	
	if !is_on_floor():
		velocity += get_gravity() * delta


## Handles the movement logic for the car
# @param delta time to proces frame
# @return void
func _keyboard_movement(delta : float) -> void:
	#resets average

	turn_input_avg = 0
	move_input_avg = 0
	
	#adds all turn and move inputs
	for key in player_inputs.keys():
		turn_input_avg += player_inputs[key].turn
		move_input_avg += player_inputs[key].move
	
	#clamps average bewteen -1 and 1
	turn_input_avg = clampi(turn_input_avg, -1, 1)
	move_input_avg = clampi(move_input_avg, -1, 1)
	
	if turn_input_avg == 0 && player_inputs.size() >= 2:
		var lowest_key : int = player_inputs.keys().reduce(_reduce)
		turn_input_avg = player_inputs[lowest_key].turn
	
	if move_input_avg == 0 && player_inputs.size() >= 2:
		var lowest_key : int = player_inputs.keys().reduce(_reduce)
		move_input_avg = player_inputs[lowest_key].move
	
	#rotates mesh
	if !input_disable:
		rotation.y += turn_input_avg * turn_speed * delta
	
	if move_input_avg && !input_disable: #handles logic if player is moving 
		var forward : Vector3 = -transform.basis.z.normalized()
		
		velocity = velocity.move_toward(
		forward * (speed if move_input_avg == 1 else speed/2) 
		* move_input_avg, acceleration * delta)
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
	


# adds input into player_input
@rpc("authority", "call_local", "unreliable")
func _on_received_input(peer_id: int, move : int, turn : int, time : int):
	var actual_time = time - time_start
	#print(str(peer_id)+": " +str(actual_time))
	if !player_inputs.has(peer_id) or actual_time > player_inputs[peer_id]["time"]:
		player_inputs[peer_id] = {
			"move" : move,
			"turn" : turn,
			"time" : actual_time
		}

func disable_input(disable : bool):
	input_disable = disable


func _reduce(a : int, b : int): 
	return a if player_inputs[a].time > player_inputs[b].time else b

var _direction

func _controller_movement(delta: float):
	var input_dir = Input.get_vector("Left", "Right", "Up", "Down") # X: Left/Right, Y: Forward/Back

	if input_dir.length() < 0.1:
		velocity = velocity.move_toward(Vector3.ZERO, decceleration * delta)
		move_and_slide()
		return

	# Convert 2D input direction into camera-relative 3D direction
	var cam_forward = camera.global_transform.basis.z
	var cam_right = camera.global_transform.basis.x
	
	# Flatten the camera vectors (ignore Y to keep movement horizontal)
	cam_forward.y = 0
	cam_right.y = 0
	cam_forward = cam_forward.normalized()
	cam_right = cam_right.normalized()

	var move_dir = (cam_forward * input_dir.y + cam_right * input_dir.x).normalized()
	
	# Rotate character toward movement direction
	var target_rot = atan2(-move_dir.x, -move_dir.z)
	rotation.y = lerp_angle(rotation.y, target_rot, delta * turn_speed * 1.5)

	# Accelerate toward movement direction
	velocity = velocity.move_toward(move_dir * speed / 1.5, acceleration * delta)

	move_and_slide()
