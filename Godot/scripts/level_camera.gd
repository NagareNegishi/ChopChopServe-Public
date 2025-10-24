extends Camera3D

@export var sway_strength_horizontal: float = 2  # max horizontal sway
@export var sway_strength_vertical: float = 0.5    # max vertical sway
@export var sway_speed: float = 0.05          # how quickly it reacts
@export var max_sway_horizontal: float = 2     # clamp horizontal sway
@export var max_sway_vertical: float = 0.5        # clamp vertical sway
@export var handheld : bool = false
var _sway_offset := Vector3.ZERO
var _base_position: Vector3

func _ready():
	_base_position = global_transform.origin

func _process(delta: float) -> void:
	var players = get_tree().get_nodes_in_group("Players")
	if handheld: handheldf()
	if players.is_empty():
		return
	
	# --- compute average velocity ---
	var avg_vel : Vector3 = Vector3.ZERO
	for player in players:
		avg_vel += player.velocity
	avg_vel /= players.size()

	# --- compute horizontal (local X) and vertical (local Y) motion ---
	var local_x := global_transform.basis.x
	var local_y := global_transform.basis.y

	var horizontal_motion := avg_vel.dot(local_x)
	var vertical_motion := avg_vel.dot(local_y)

	# --- compute target offsets ---
	var target_offset : Vector3 = Vector3.ZERO
	target_offset.x = clamp(horizontal_motion * sway_strength_horizontal, -max_sway_horizontal, max_sway_horizontal)
	target_offset.y = clamp(vertical_motion * sway_strength_vertical, -max_sway_vertical, max_sway_vertical)

	# --- smooth interpolation ---
	_sway_offset = _sway_offset.lerp(target_offset, 1.0 - pow(0.001, delta * sway_speed))

	# --- apply offset relative to base position ---
	global_transform.origin = _base_position + local_x * _sway_offset.x + local_y * _sway_offset.y

var _time_offset := randf() * 100  # Random starting point for variation

func handheldf():
	_time_offset += sway_speed  # Increment time to progress motion
	
	# Use smooth noise for natural motion
	var noise_x = sin(_time_offset * 0.9 + 10.0) * 0.5 + sin(_time_offset * 1.1) * 0.5
	var noise_y = sin(_time_offset * 1.3) * 0.5 + sin(_time_offset * 0.8 + 5.0) * 0.5

	# Target offset using generated noise
	var target_offset = Vector3.ZERO
	target_offset.x = clamp(noise_x * sway_strength_horizontal, -max_sway_horizontal, max_sway_horizontal)
	target_offset.y = clamp(noise_y * sway_strength_vertical, -max_sway_vertical, max_sway_vertical)

	# Smoothly interpolate to new target (same as in _process)
	_sway_offset = _sway_offset.lerp(target_offset, 1.0 - pow(0.001, sway_speed/2 * get_process_delta_time()))

	# Apply sway
	var local_x = global_transform.basis.x
	var local_y = global_transform.basis.y
	global_transform.origin = _base_position + local_x * _sway_offset.x + local_y * _sway_offset.y
