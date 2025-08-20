class_name PlayerCar
extends CharacterBody3D


@export var speed : float = 3
@export var turn_speed : float = 3
@export var acceleration : float = 15
@export var decceleration : float = 30


@onready var controller : PlayerCarController = $Controller
@onready var camera : Camera3D = $SpringArm/Camera


var move_particle = preload("res://Particles/MoveParticles.tscn")
var MOVE_PARTICLES_POOL = []


## Called when the node enters the scene tree for the first time.
## @return void
func _ready() -> void:
	for i in range(10):
		var particle = move_particle.instantiate()
		MOVE_PARTICLES_POOL.append(particle)

# Runs every process frame
# @param delta time to proces frame
# @return void
func _process(delta: float) -> void:
	_movement(delta)
	
	if !is_on_floor():
		velocity += get_gravity() * delta
	

# Handles the movement logic for the car
# @param delta time to proces frame
# @return void
func _movement(delta : float) -> void:
	#rotates mesh
	$Mesh.rotation.y += controller.turn_input * turn_speed * delta
	
	if controller.move_input: #handles logic if player is moving 
		var forward : Vector3 = -$Mesh.transform.basis.z.normalized()
		
		#halves the speed of player if in reverse
		velocity.x = move_toward(velocity.x, 
		forward.x * (speed if controller.move_input == 1 else speed/2) 
		* controller.move_input, acceleration * delta)
		
		velocity.z = move_toward(velocity.z, 
		forward.z * (speed if controller.move_input == 1 else speed/2) 
		* controller.move_input, acceleration * delta)
	else: #declerates player if not moving 
		velocity.x = move_toward(velocity.x, 0, decceleration * delta)
		velocity.z = move_toward(velocity.z, 0, decceleration * delta)
	
	move_and_slide()

# Uses unactive particles from pool and actives them if player is moving
# @return void
func _on_particle_timer_timeout() -> void:
	if (velocity == Vector3.ZERO || controller.move_input == -1) && controller.turn_input == 0:
		return
	
	var particle_ref : MoveParticles = null

	for particle : MoveParticles in MOVE_PARTICLES_POOL:
		if !particle.is_active:
			particle_ref = particle
			break

	if particle_ref == null:
		return

	particle_ref.set_active(true)
	
	if particle_ref.get_parent() != get_tree().get_current_scene():
		get_tree().get_current_scene().add_child(particle_ref)
		
	particle_ref.global_transform = $Mesh/ParticleSpawn.global_transform
