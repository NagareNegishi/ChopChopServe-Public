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
var MOVE_PARTICLES_POOL = []
var _direction : Vector3 = Vector3.FORWARD
var _items_in_interactable_area = []
var _closest_item : InteractableComponent = null
var move_particle = preload("res://Particles/MoveParticles.tscn")
var item_in_hand : Node3D = null
var can_dash : bool = true

@onready var controller : PlayerController = $Controller
@onready var player_state : PlayerState = $PlayerState
@onready var item_point = $Mesh/ItemPoint
@onready var check_interactables : Timer = $CheckInteractables

func _enter_tree() -> void:
	scale = Vector3(1,1,1)
	


## Called when the node enters the scene tree for the first time.
## @return void
func _ready() -> void:
	$DashCooldown.wait_time = DASH_COOLDOWN
	player_state.player_id = name.to_int()
	set_multiplayer_authority(name.to_int())
	
	if multiplayer.get_unique_id() == name.to_int():
		$Decal.modulate = GlobalScript.player_outline_colours.get(randi() % 3)
		set_team(randi() % 2 + 1)
		print("Team: ",  get_team())
	else:
		check_interactables.stop()
	
	
	for i in range(10):
		var particle = move_particle.instantiate()
		MOVE_PARTICLES_POOL.append(particle)
	


## Functionailty that happens every frame
## @param delta the times it takes per frame to render
## @return void
func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	
	# Add the gravity.
	if !is_on_floor():
		velocity += get_gravity() * delta
		
	_inputs()
	_movement(delta)
	collision_check()
	_rotate_player(delta)
	

func collision_check() -> void:
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i)
		if collider.get_collider() is RigidBody3D:
			collider.get_collider().apply_central_impulse(-collider.get_normal() * PUSH_FORCE)


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
	_direction = (transform.basis * Vector3(controller.input_dir.x, 0, controller.input_dir.y)).normalized()
	
	if _direction:
		velocity.x = move_toward(velocity.x, _direction.x * SPEED, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, _direction.z * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * SPEED)
		velocity.z = move_toward(velocity.z, 0, DECELERATION * SPEED)
		
	move_and_slide()


## Allows player to dash again after cooldown finshed
## @return void
func _on_dash_timer_timeout() -> void:
	can_dash = true;

## Performs the dash and starts the dash cooldown
## @return void
func _dash(is_forward : bool) -> void:
	
	var dash_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	
	# If player moving it will launch in direction of movement 
	# otherwise will do where players looking
	var _dash_direction = ($Mesh.transform.basis.z if is_forward
	else -$Mesh.transform.basis.z).normalized() 
	
	dash_tween.tween_property(self, "velocity", _dash_direction * (DASH_STRENGTH 
	if is_forward else DASH_STRENGTH / 2.5), DASH_DURATION)
	
	if is_forward:
		can_dash = false
		$DashCooldown.start()


## Handles all the inputs
## @return void
func _inputs() -> void:
	if Input.is_action_just_pressed("Dash") && can_dash:
		_dash(true)
		
	if Input.is_action_just_pressed("Interact"):
		_interact()
		
	if Input.is_action_just_pressed("Throw"):
		server_drop_item(get_path(), true)
		
	if Input.is_action_just_pressed("Action"):
		_action(true)
		
	if Input.is_action_just_released("Action"):
		_action(false)


func _interact() -> void:
	if (((item_in_hand is Plate  || item_in_hand is Cookware) && _closest_item != null) && 
	(_closest_item.get_parent() is Food || _closest_item.get_parent() is Appliance)):
		_closest_item.interact()
		return
	
	elif (item_in_hand != null && (_closest_item == null || 
	_closest_item != null && _closest_item.is_pickup)):
		server_drop_item(self.get_path(), false)
	
	if _closest_item == null:
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
	if item_in_hand != null && item_in_hand.get_node("InteractableComponent").has_action:
		item_in_hand.get_node("InteractableComponent").action(is_active)
		return
	
	if _closest_item == null || item_in_hand != null:
		return
	
	_closest_item.action(is_active)


## Sets what item the player is holding
## @return bool if successfully picked up
func pickup_item(item : Node3D) -> bool:
	if(item == null):
		push_error("item invalid")
		return false
	
	if(!item.get_node("InteractableComponent").is_pickup):
		push_error("not pickup")
		return false
	
	if item_in_hand:
		drop_item(false)
	
	item.global_position = Vector3(0,0,0)
	item.global_rotation = Vector3(0,0,0)
#----------------------------------------------------------
# Added small change here
	if item.get_parent():
		item.get_parent().remove_child(item)
#----------------------------------------------------------
	if item.has_method("turnOnPhysics"):
		item.turnOnPhysics(false)
	
	if item.has_node("InteractableComponent"):
		item.get_node("InteractableComponent").turn_on_collision(false)
	
	$Mesh/ItemPoint.add_child(item)
	call_deferred("_final_pickup", item)

	
	item_in_hand = item
	
	return true


@rpc("authority", "call_local")
func server_pickup(player_name : String, item_name : String) -> void:
	var player : Node3D = get_tree().current_scene.get_node(player_name)
	var item : Node3D = get_tree().current_scene.get_node(item_name)
	
	if !item or !player:
		return
	
	rpc("_client_pickup", player_name, item_name)
	
	
## Sets what item the player is holding
## @return bool if successfully picked up
@rpc("any_peer", "call_local")
func _client_pickup(player_path : String, item_path : String) -> bool:
	var item : Node3D = get_tree().current_scene.get_node(item_path)
	var player : Node3D = get_tree().current_scene.get_node(player_path)
	
	if(item == null):
		push_error("item invalid")
		return false
	
	if(!item.get_node("InteractableComponent").is_pickup):
		push_error("not pickup")
		return false
	
	if player.item_in_hand:
		player.rpc_id(1, "server_drop_item", false)
	
	item.global_position = Vector3(0,0,0)
	item.global_rotation = Vector3(0,0,0)
#----------------------------------------------------------
# Added small change here
	if item.get_parent():
		item.get_parent().remove_child(item)
#----------------------------------------------------------
	if item.has_method("turnOnPhysics"):
		item.turnOnPhysics(false)
	
	if item.has_node("InteractableComponent"):
		item.get_node("InteractableComponent").turn_on_collision(false)
	
	player.item_point.add_child(item)
	player.call_deferred("_final_pickup", item)

	
	item_in_hand = item
	
	return true


@rpc("authority", "call_local")
func server_drop_item(player_path : String, is_throw : bool) -> bool:
	var player : Node3D = get_tree().current_scene.get_node(player_path)
	print("print")
	if(player.item_in_hand == null):
		return false
	rpc("_client_drop_item",player_path, is_throw)
	return true


@rpc("any_peer", "call_local")
func _client_drop_item(player_path : String, is_throw : bool) -> bool:
	var player : Node3D = get_tree().current_scene.get_node(player_path)
	
	if player.item_in_hand.get_parent():
		player.item_in_hand.get_parent().remove_child(player.item_in_hand)
		
	if player.item_in_hand.has_node("InteractableComponent"):
		player.item_in_hand.get_node("InteractableComponent").turn_on_collision(true)
	
	get_tree().get_current_scene().add_child(player.item_in_hand)
	player.call_deferred("_final_drop", player.item_in_hand)
	

	player._action(false)

	if player.item_in_hand.has_method("turnOnPhysics"):
		player.item_in_hand.turnOnPhysics(true)

	if is_throw && player.item_in_hand is AbstractThrowable:
		player.item_in_hand.linear_velocity = $Mesh.global_transform.basis.z * THROW_STRENGTH
		
	print("Item dropped ", player.item_in_hand)
	player.item_in_hand = null
	return true



## drops item in hand in front of player
## @return bool if dropped item succesfully
func drop_item(is_throw : bool) -> bool:
	
	if(item_in_hand == null):
		return false
	
	if item_in_hand.get_parent():
		item_in_hand.get_parent().remove_child(item_in_hand)
		
	if item_in_hand.has_node("InteractableComponent"):
		item_in_hand.get_node("InteractableComponent").turn_on_collision(true)
	
	get_tree().get_current_scene().add_child(item_in_hand)
	call_deferred("_final_drop", item_in_hand)
	

	_action(false)

	if item_in_hand.has_method("turnOnPhysics"):
		item_in_hand.turnOnPhysics(true)

	if is_throw && item_in_hand is AbstractThrowable:
		item_in_hand.linear_velocity = $Mesh.global_transform.basis.z * THROW_STRENGTH
		
	print("Item dropped ", item_in_hand)
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


## Handles the move particles on the player when they move
## @return void
func _on_move_particles_timeout() -> void:
	if velocity == Vector3.ZERO:
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
		
	particle_ref.global_transform = $Mesh/movePoint.global_transform


## Removes current item from the playes hand and its parent
## @return Node3D the item that was removed from the players hand
func remove_item() -> Node3D:
	#return item_in_hand
	if item_in_hand == null:
		return null
		
	item_in_hand.get_parent().remove_child(item_in_hand)
	
	item_in_hand.global_position = $Mesh/ItemPoint.global_position + $Mesh.global_transform.basis.z * 2.5
	item_in_hand.global_rotation = $Mesh/ItemPoint.global_rotation
	
	item_in_hand.scale = $Mesh/ItemPoint.global_transform.basis.get_scale() / item_in_hand.global_transform.basis.get_scale()
	
	var res = item_in_hand
	item_in_hand = null
	print("Item removed")
	return res


## Handles the scale of the item when item is picked up
## @return void
func _final_pickup(item: Node3D) -> void:
	var scale = Transform3D().basis.get_scale()
	item.scale = scale / $Mesh/ItemPoint.global_transform.basis.get_scale()


## Handles the transform when the item is dropped
## @return void
func _final_drop(item: Node3D) -> void:
	var scale = Transform3D().basis.get_scale()
	item.scale = ($Mesh/ItemPoint.global_transform.basis.get_scale() / scale)
	item.global_position = $Mesh/ItemPoint.global_position + $Mesh.global_transform.basis.z * 2.5
	item.global_rotation = $Mesh/ItemPoint.global_rotation


## Assigns the player a team
## @param team the teamm you want to assign the player
## @return void
func set_team(team : GlobalScript.Team):
	player_state.team = team


## Gets the team on the player
## @return GlobalScript.Team what team the player is assigned
func get_team() -> GlobalScript.Team:
	return player_state.team


## Sets the players name
## @param String the players new name
## @return void
func set_player_name(name : String):
	player_state.player_name = name


## Gets the players name
## @return String the players name
func get_player_name() -> String:
	return player_state.player_name
