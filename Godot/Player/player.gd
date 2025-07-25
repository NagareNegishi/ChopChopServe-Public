extends CharacterBody3D

const SPEED : float = 4

var _direction : Vector3 = Vector3.FORWARD
var _dash_strength : float = 1.5
var _angular_aceleration : float = 7
var _items_in_interactable_area = []
var _closest_item = null

var item_in_hand = null
var can_dash : bool = true

## Functionailty that happens every frame
## @param delta The times it takes per frame to render
## @return void
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if !is_on_floor():
		velocity += get_gravity() * delta
		
	_inputs()
	_movement()
	_rotate_player(delta)


## Rotates player to the direction they are moving
## @param delta The times it takes per frame to render
## @return void
func _rotate_player(delta: float):
	if(_direction.length() > 0):
		$Mesh.rotation.y = lerp_angle($Mesh.rotation.y, atan2(_direction.x -0.25, _direction.z), delta * _angular_aceleration)


## Hanles movement logic for player
## @return void
func _movement() -> void:
	var input_dir := Input.get_vector("Up", "Down", "Right", "Left")
	_direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if _direction:
		velocity.x = _direction.x * SPEED
		velocity.z = _direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	#velocity.y = 0;
	move_and_slide()


## Allows player to dash again after cooldown finshed
## @return void
func _on_dash_timer_timeout() -> void:
	can_dash = true;


## Performs the dash and starts the dash cooldown
## @return void
func _dash() -> void:
	can_dash = false;
	var tween = create_tween()
	
	#If player moving it will launch in direction of movement, otherwise will do where players looking
	var _dash_direction = position + (_direction  if _direction.length() != 0 else $Mesh.transform.basis.z).normalized() * _dash_strength
	
	tween.tween_property(self, "position", _dash_direction, 0.1)
	$DashCooldown.start()


## Handles all the inputs
## @return void
func _inputs() -> void:
	if Input.is_action_just_pressed("Dash") && can_dash:
		_dash()
		
	if Input.is_action_just_pressed("Interact"):
		_interact()
		
	if Input.is_action_just_pressed("Throw"):
		_throw()


## Handles when the player interacts
## @return void
func _interact() -> void:
	if _closest_item == null || !_closest_item.has_method("interact"):
		print("Not interactable!")
		return
	
	_closest_item.interact()
	setItemInHand(null);

## Handles the logic for when player throws item
## @return void
func _throw() -> void:
	print()
	

## Handles logic when player uses an action
## @return void
func _action() -> void:
	print()


## Sets what item the player is holding
## @return void
func setItemInHand(item) -> void:
	if(item == null):
		push_error("item invalid")
		return
	item_in_hand = item


## Adds area to _items_in_interactable_area
## @param area the area3D that entered interactable range
## @return void
func _on_interact_area_area_entered(area: Area3D) -> void:
	_items_in_interactable_area.append(area)


## Erases area from _items_in_interactable_area 
## @param area the area3D that left the interactable range
## @return void
func _on_interact_area_area_exited(area: Area3D) -> void:
	_items_in_interactable_area.erase(area)


## Finds the closest interactables is
## @return void
func _on_check_interactables_timeout() -> void:
	if _items_in_interactable_area.size() <= 0:
		return

	var closest_item = _items_in_interactable_area[0]
	var closest_distance = global_position.distance_to(closest_item.global_position)

	#Loops through all items in range and finds closest one
	for item in _items_in_interactable_area:
		var distance = global_position.distance_to(item.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_item = item

	_closest_item = closest_item
