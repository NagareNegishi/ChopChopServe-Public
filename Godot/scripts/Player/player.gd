class_name Player 
extends CharacterBody3D

const SPEED : float = 4.0
const ACCELERATION : float = 100
const DECELERATION : float = 60
const DASH_DURATION : float = 0.025
const DASH_STRENGTH : float = 20
const DASH_COOLDOWN : float = 0.2
const ANGULAR_ACCELERATION : float = 15
const PUSH_FORCE : float = 0.3
const THROW_STRENGTH : float = 40

var _direction : Vector3 = Vector3.FORWARD
var _items_in_interactable_area = []
var _closest_item : InteractableComponent = null
var move_particle = preload("res://Particles/MoveParticles.tscn")
var item_in_hand : Node3D = null
var can_dash : bool = true


## Called when the node enters the scene tree for the first time.
## @return void
func _ready() -> void:
	$DashCooldown.wait_time = DASH_COOLDOWN
	$Decal.modulate = GlobalScript.playerColours.get(1)

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
func _rotate_player(delta: float) -> void:
	if(_direction.length() > 0):
		$Mesh.rotation.y = lerp_angle($Mesh.rotation.y, atan2(_direction.x, _direction.z), delta * ANGULAR_ACCELERATION)


## Handles movement logic for player
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
	
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i)
		if collider.get_collider() is RigidBody3D:
			collider.get_collider().apply_central_impulse(-collider.get_normal() * PUSH_FORCE)


## Allows player to dash again after cooldown finshed
## @return void
func _on_dash_timer_timeout() -> void:
	can_dash = true;

## Performs the dash and starts the dash cooldown
## @return void
func _dash() -> void:
	can_dash = false
	var dash_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	
	# If player moving it will launch in direction of movement 
	# otherwise will do where players looking
	var _dash_direction = (_direction if _direction.length() != 0 else -$Mesh.transform.basis.z).normalized() 
	
	
	dash_tween.tween_property(self, "velocity", _dash_direction * DASH_STRENGTH, DASH_DURATION)
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
		
	if Input.is_action_just_pressed("Action"):
		_action(true)
		
	if Input.is_action_just_released("Action"):
		_action(false)


## Handles when the player interacts
## @return void
func _interact() -> void:
	if item_in_hand != null:
		drop_item(false)
	
	if _closest_item == null || !_closest_item is InteractableComponent:
		return
	 
	_closest_item.interact()


## Handles the logic for when player throws item
## @return void
func _throw() -> void:
	if item_in_hand == null || !item_in_hand is AbstractThrowable:
		return
	
	drop_item(true)
	


## Handles logic when player uses an action
## @return void
func _action(is_active : bool) -> void:
	if item_in_hand == null:
		return
		
	item_in_hand.get_node("InteractableComponent").action(is_active)


## Sets what item the player is holding
## @return bool if successfully picked up
func pickup_item(item : Node3D) -> bool:
	if(item == null):
		push_error("item invalid")
		return false
	
	if(!item.get_node("InteractableComponent").is_pickup):
		push_error("not pickup")
		return false
	
	item.global_position = Vector3(0,0,0)
	item.global_rotation = Vector3(0,0,0)
	item.get_parent().remove_child(item)
	
	if item is AbstractThrowable:
		item.turnOnPhysics(false)
	
	if item.has_node("InteractableComponent"):
		item.get_node("InteractableComponent").turn_on_collision(false)
	
	var original_global_scale = item.global_transform.basis.get_scale()
	$Mesh/ItemPoint.add_child(item)
	item.scale = original_global_scale / $Mesh/ItemPoint.global_transform.basis.get_scale()
	item_in_hand = item
	
	return true

## drops item in hand in front of player
## @return bool if dropped item succesfully
func drop_item(is_throw : bool) -> bool:
	if(item_in_hand == null):
		return false
	
	item_in_hand.get_parent().remove_child(item_in_hand)
	if item_in_hand.has_node("InteractableComponent"):
		item_in_hand.get_node("InteractableComponent").turn_on_collision(true)
	
	item_in_hand.scale = $Mesh/ItemPoint.global_transform.basis.get_scale() / item_in_hand.global_transform.basis.get_scale()
	
	get_tree().get_current_scene().add_child(item_in_hand)
	
	item_in_hand.global_position = $Mesh/ItemPoint.global_position + $Mesh.global_transform.basis.z * 2.5
	item_in_hand.global_rotation = $Mesh/ItemPoint.global_rotation
	
	_action(false)
	
	if item_in_hand is AbstractThrowable:
		item_in_hand.turnOnPhysics(true)
		
	if is_throw && item_in_hand is AbstractThrowable:
		item_in_hand.linear_velocity = $Mesh.global_transform.basis.z * THROW_STRENGTH
		
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


	


func _on_move_particles_timeout() -> void:
	if velocity == Vector3.ZERO:
		return
	var move_particle_instance = move_particle.instantiate()
	get_tree().get_current_scene().add_child(move_particle_instance)
	move_particle_instance.global_transform = $Mesh/movePoint.global_transform
