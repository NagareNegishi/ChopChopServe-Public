extends SpringArm3D

var current_position: Vector3
@export var lag_speed : float = 5.0

func _ready():
	current_position = global_position

func _process(delta):
	var target_position = get_parent().global_transform.origin
	current_position = current_position.lerp(target_position, delta * lag_speed)
	global_transform.origin = current_position
