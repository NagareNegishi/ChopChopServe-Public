class_name Player extends CharacterBody3D

const SPEED : float = 4.0
const ACCELERATION : float = 20.0
const DECELERATION : float = 40.0
const DASH_DURATION: float = 0.1 
const DASH_STRENGTH : float = 10.5
const ANGULAR_ACCELERATION : float = 9
const ITEM_SCALING : float = 5.5

var _direction : Vector3 = Vector3.FORWARD
var _items_in_interactable_area = []
var _closest_item : InteractableComponent = null
var item_in_hand : AbstractPickup = null
var can_dash : bool = true

## Functionailty that happens every frame
## @param delta the times it takes per frame to render
## @return void
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if !is_on_floor():
		velocity += get_gravity() * delta
		
	_inputs()
	_movement(delta)
	_rotate_player(delta)


## Rotates player to the direction they are moving
## @param delta The times it takes per frame to render
## @return void
func _rotate_player(delta: float):
	if(_direction.length() > 0):
		$Mesh.rotation.y = lerp_angle($Mesh.rotation.y, atan2(_direction.x, _direction.z), delta * ANGULAR_ACCELERATION)


## Hanles movement logic for player
## @param delta the delta from process physics
## @return void
func _movement(delta : float) -> void:
	var input_dir := Input.get_vector("Up", "Down", "Right", "Left")
	_direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if _direction:
		velocity.x = move_toward(velocity.x, _direction.x * SPEED, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, _direction.z * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION * SPEED)
		velocity.z = move_toward(velocity.z, 0, DECELERATION * SPEED)
	
	move_and_slide()


## Allows player to dash again after cooldown finshed
## @return void
func _on_dash_timer_timeout() -> void:
	can_dash = true;


## Performs the dash and starts the dash cooldown
## @return void
func _dash() -> void:
	can_dash = false
	var tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	
	# If player moving it will launch in direction of movement 
	# otherwise will do where players looking
	var _dash_direction = (_direction if _direction.length() != 0 else -$Mesh.transform.basis.z).normalized() 

	tween.tween_property(self, "velocity", _dash_direction * DASH_STRENGTH, DASH_DURATION)
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
	if item_in_hand != null:
		drop_item()
		
	if _closest_item == null || !_closest_item is InteractableComponent:
		return

	_closest_item.interact()


## Handles the logic for when player throws item
## @return void
func _throw() -> void:
	print()
	

## Handles logic when player uses an action
## @return void
func _action() -> void:
	print()


## Sets what item the player is holding
## @return bool if successfully picked up
func pickup_item(item : AbstractPickup) -> bool:
	if(item == null):
		push_error("item invalid")
		return false
	item.global_position = Vector3(0,0,0)
	item.get_parent().remove_child(item)
	item.turn_on_collision(false)
	$Mesh/ItemPoint.add_child(item)
	item.scale *= ITEM_SCALING
	item_in_hand = item
	
	return true


func drop_item() -> bool:
	if(item_in_hand == null):
		return false
	
	item_in_hand.scale *= 1 / ITEM_SCALING
	item_in_hand.get_parent().remove_child(item_in_hand)
	item_in_hand.turn_on_collision(true)
	get_tree().get_current_scene().add_child(item_in_hand)
	
	item_in_hand.global_position = $Mesh/ItemPoint.global_position
	item_in_hand = null
	return true


## Adds area to _items_in_interactable_area
## @param area the area3D that entered interactable range
## @return void
func _on_interact_area_area_entered(area: Area3D) -> void:
	if !area is InteractableComponent:
		return
	
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
		if _closest_item != null:
			_closest_item.hover(false)
		_closest_item = null
		return
	
	var closest_item = _items_in_interactable_area[0]
	var closest_distance = global_position.distance_to(closest_item.global_position)

	#Loops through all items in range and finds closest one
	for item in _items_in_interactable_area:
		var distance = global_position.distance_to(item.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_item = item
	
	if(_closest_item != closest_item):
		closest_item.hover(true)
	
	_closest_item = closest_item
