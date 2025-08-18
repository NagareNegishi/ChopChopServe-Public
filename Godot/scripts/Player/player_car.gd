class_name PlayerCar
extends CharacterBody3D

const SPEED : float = 150
const ACCELERATION : float = 100
const DECELERATION : float = 60
const ANGULAR_ACCELERATION : float = 3.5

var move_dir : Vector3 = Vector3.ZERO

@onready var controller : PlayerCarController = $Controller
@onready var camera : Camera3D = $SpringArm/Camera

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	_movement(delta)
	_rotate_car(delta)
	
func _movement(delta : float) -> void:
	velocity = Vector3.ZERO
	move_dir = Vector3.ZERO
	
	if controller.input_direction.length() <= 0:
		return
	
	controller.input_direction = controller.input_direction.normalized()
		
	var cam_forward = -camera.global_transform.basis.z
	cam_forward.y = 0
	cam_forward = cam_forward.normalized()
		
	var cam_right = camera.global_transform.basis.x
	cam_right.y = 0
	cam_right = cam_right.normalized()
		
	move_dir = ((cam_forward * -controller.input_direction.y) 
	+ (cam_right * controller.input_direction.x)).normalized()
		
	velocity.x = move_dir.x * SPEED * delta
	velocity.z = move_dir.z * SPEED * delta
	move_and_slide()

func _rotate_car(delta: float) -> void:
	if(move_dir.length() > 0):
		var target_basis = Basis().looking_at(move_dir, Vector3.UP)
		$Mesh.global_transform.basis = $Mesh.global_transform.basis.slerp(target_basis, ANGULAR_ACCELERATION * delta)
		
