extends CharacterBody3D

const SPEED : float = 4

var _direction : Vector3 = Vector3.FORWARD
var _can_dash : bool = true
var _dash_direction : Vector3 = Vector3.FORWARD
var _angular_aceleration : float = 7


## Functionailty that happens every frame
## @param delta The times it takes per frame to render
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	_inputs()
	_movement()
	_rotate_player(delta)


## Rotates player to the direction they are moving
## @param delta The times it takes per frame to render
func _rotate_player(delta: float):
	if(_direction.length() > 0):
		$Mesh.rotation.y = lerp_angle($Mesh.rotation.y, atan2(_direction.x -0.25, _direction.z), delta * _angular_aceleration)


## Hanles movement logic for player  
func _movement():
	var input_dir := Input.get_vector("Up", "Down", "Right", "Left")
	_direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if _direction:
		velocity.x = _direction.x * SPEED
		velocity.z = _direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	velocity.y = 0;
	move_and_slide()


## Allows player to dash again after cooldown finshed
func _on_dash_timer_timeout() -> void:
	_can_dash = true;


## Performs the dash and starts the dash cooldown
func _dash():
	_can_dash = false;
	var tween = create_tween()
	_dash_direction = position + _direction.normalized() * 1.5
	tween.tween_property(self, "position", _dash_direction, 0.1)
	$DashCooldown.start()


## Handles all the inputs
func _inputs():
	if Input.is_action_pressed("Dash") && _can_dash:
		_dash()
		
	if Input.is_action_pressed("Interact"):
		_interact()
		
	if Input.is_action_pressed("Throw"):
		_throw()


## Handles when the player interacts
func _interact():
	print()


## Handles the logic for when player throws item
func _throw():
	print()


## Handles logic when player uses an action
func _action():
	print()
