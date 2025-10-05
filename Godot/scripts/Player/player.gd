class_name Player 
extends CharacterBody3D

signal comp_hovered(cop : InteractableComponent, is_hover : bool)
signal item_dropped(item : Node3D)

const ACCELERATION : float = 100
const DECELERATION : float = 60
const DASH_DURATION : float = 0.025
const DASH_STRENGTH : float = 20
const DASH_COOLDOWN : float = 0.2
const ANGULAR_ACCELERATION : float = 15
const PUSH_FORCE : float = 0.3
const THROW_STRENGTH : float = 40

var speed : float = 4.0
var MOVE_PARTICLES_POOL = []
var _direction : Vector3 = Vector3.FORWARD
var _items_in_interactable_area = []
var _closest_item : InteractableComponent = null
var move_particle = preload("res://Particles/MoveParticles.tscn")
var item_in_hand : Node3D = null
var can_dash : bool = true
var is_controls_disabled = false
var is_actoin_disabled = false
var is_inverted = false

@onready var controller : PlayerController = $Controller
@onready var item_point = $Mesh/ItemPoint
@onready var check_interactables : Timer = $CheckInteractables
@onready var anim_tree : AnimationTree = $AnimationTree
@onready var body_mesh : MeshInstance3D = $Mesh/Armature/Skeleton3D/Frog
@onready var name_tag : NameTag = $Mesh/NameTag/SubViewport/UiNameTag

func _enter_tree() -> void:
	scale = Vector3(1,1,1)
	

func _sabotage(num):
	SabotageSystem.rpc("request_sabotage", ENetManager.get_my_team(), num)

## Called when the node enters the scene tree for the first time.
## @return void
func _ready() -> void:
	$DashCooldown.wait_time = DASH_COOLDOWN

	call_deferred("set_multiplayer_authority", name.to_int())
	#Sets the default animation values
	anim_tree["parameters/conditions/is_idle"] = true
	anim_tree["parameters/conditions/is_moving"] = false
	anim_tree["parameters/conditions/action"] = false
	anim_tree["parameters/conditions/unaction"] = false
	anim_tree["parameters/SM_Walking/conditions/empty"] = true
	anim_tree["parameters/SM_IDLE/conditions/empty"] = true
	anim_tree["parameters/SM_Walking/conditions/holding"] = false
	anim_tree["parameters/SM_IDLE/conditions/holding"] = false
	anim_tree["parameters/SM_ACTION/conditions/chopping"] = false
	
	var colour : Color = GlobalScript.player_outline_colours.get(
			ENetManager.get_player_list().find(name.to_int()))
	var material : Material = StandardMaterial3D.new()
	material.albedo_color = colour
	name_tag.set_color(name.to_int())
	
	$Decal.modulate = colour
	body_mesh.set_surface_override_material(1, material)
	$Mesh/Armature/Skeleton3D/RightHand.set_surface_override_material(1, material)
	$Mesh/Armature/Skeleton3D/LeftHand.set_surface_override_material(1, material)
	
	if !multiplayer.get_unique_id() == name.to_int():
		check_interactables.stop()	
	
	for i in range(10):
		var particle = move_particle.instantiate()
		MOVE_PARTICLES_POOL.append(particle)
	
	if !multiplayer.get_unique_id() == name.to_int() : return
	
	await get_tree().create_timer(0.1).timeout
	add_to_group("Players")
	rpc_id(1, "_server_set_name", name.to_int(), GlobalScript.player_name)


func set_speed(new_speed : float) -> void:
	speed = max(new_speed, 0)

@rpc("any_peer", "call_local")
func _set_player_name(id : int, p_name : String):
	var player : Player = GlobalScript.get_local_player_by_id(id)
	player.name_tag.set_tag(p_name)

@rpc("authority", "call_local")
func _server_set_name(id : int, p_name : String):
	rpc("_set_player_name", id, p_name)
	
	

## Functionailty that happens every frame
## @param delta the times it takes per frame to render
## @return void
func _physics_process(delta: float) -> void:
	invert_controls(true)
	if ENetManager.is_host():
		collision_check()
	
	if velocity == Vector3.ZERO:
		anim_tree["parameters/conditions/is_idle"] = true
		anim_tree["parameters/conditions/is_moving"] = false
	else:
		anim_tree["parameters/conditions/is_moving"] = true
		anim_tree["parameters/conditions/is_idle"] = false
	
	if multiplayer.get_unique_id() != name.to_int():
		return
	
	# Add the gravity.
	if !is_on_floor():
		velocity += get_gravity() * delta
		
	_inputs()
	_movement(delta)
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
		$Mesh.rotation.y = lerp_angle($Mesh.rotation.y, 
		atan2(_direction.x, _direction.z), delta * ANGULAR_ACCELERATION)


## Handles movement logic for player
## @param delta the delta from process physics
## @return void
func _movement(delta : float) -> void:
	if is_controls_disabled: return
	_direction = (transform.basis * 
	Vector3(controller.input_dir.x, 0, controller.input_dir.y)).normalized()
	
	if _direction:
		velocity.x = move_toward(velocity.x, _direction.x * speed, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, _direction.z * speed, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * speed)
		velocity.z = move_toward(velocity.z, 0, DECELERATION * speed)
	
	move_and_slide()


## Allows player to dash again after cooldown finshed
## @return void
func _on_dash_timer_timeout() -> void:
	can_dash = true;

## Performs the dash and starts the dash cooldown
## @return void
func _dash(is_forward : bool) -> void:
	if !velocity || !is_on_floor():
		return
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
	if Input.is_action_just_pressed("Pause"):
		GlobalScript.get_pause_menu().toggle_visible(true)
		
	if !is_actoin_disabled:
		if Input.is_action_just_pressed("Action"):
			_action(true)
			
		if Input.is_action_just_released("Action"):
			_action(false)
		
	if is_controls_disabled: return
	
	if Input.is_action_just_pressed("Dash") && can_dash:
		_dash(true)
		
	if Input.is_action_just_pressed("Interact"):
		_interact()
		
	if Input.is_action_just_pressed("Throw"):
		server_drop_item(get_path(), true)
	
	if Input.is_action_just_pressed("Sabotage1"): _sabotage(0)
	elif Input.is_action_just_pressed("Sabotage2"): _sabotage(1)
	elif Input.is_action_just_pressed("Sabotage3"): _sabotage(2)
	elif Input.is_action_just_pressed("Sabotage4"): _sabotage(3)
	elif Input.is_action_just_pressed("Sabotage5"): _sabotage(4)


func _interact() -> void:
	if _can_add_to_plate():
		rpc("_client_add_plate", ENetManager.get_my_id(), 
		_closest_item.get_parent().get_path())
		return
	
	elif (((item_in_hand is Plate  || item_in_hand is Cookware) && _closest_item != null) && 
	(_closest_item.get_parent() is Food || _closest_item.get_parent() is Appliance)
	) || _can_app_interact():
		_closest_item.interact()
		return
	
	elif (item_in_hand != null && (_closest_item == null || 
	_closest_item != null && _closest_item.is_pickup)):
		server_drop_item(self.get_path(), false)
	
	if (_closest_item == null || !_can_app_interact()):
		return
	_closest_item.interact()


func _can_add_to_plate() -> bool:
	return ((item_in_hand != null && item_in_hand is Plate) && 
	(_closest_item != null && _closest_item.get_parent() is Food))

@rpc("any_peer", "call_local")
func _client_add_plate(player_id : int, item_path : String):
	var player : Player = GlobalScript.get_local_player_by_id(player_id)
	var item := get_tree().current_scene.get_node(item_path)
	player.item_in_hand.add_item(item)
	

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
	
	elif _closest_item == null || item_in_hand != null:
		return
	
	
	
	if !_closest_item.has_action || (is_active && _closest_item.get_parent() is ChopTable && 
	_closest_item.get_parent().chopping_board.contents.is_empty()) || (is_active 
	&& _closest_item.get_parent() is Sink && _closest_item.get_parent().contents.is_empty()): return
	
	if _closest_item != null && (_closest_item.get_parent() is ChopTable or _closest_item.get_parent() is Sink):
		disable_controls(is_active, false)
	
	if _closest_item.get_parent() is not FoodCrateUpdate:
		rpc("_client_action_anim",ENetManager.get_my_id(), is_active,
	is_active && _closest_item.get_parent() is ChopTable,
	is_active && _closest_item.get_parent() is Sink)
	
	
	
	_closest_item.action(is_active)


@rpc("any_peer", "call_local")
func _client_action_anim(player_id : int, is_active : bool, chop : bool, sink : bool):
	var player : Player = GlobalScript.get_local_player_by_id(player_id)
	player.anim_tree["parameters/conditions/action"] = is_active
	player.anim_tree["parameters/conditions/unaction"] = !is_active
	
	if chop:
		player.anim_tree["parameters/SM_ACTION/conditions/chopping"] = true
		
	elif sink:
		player.anim_tree["parameters/SM_ACTION/conditions/washing"] = true
	
	if !is_active:
		player.anim_tree["parameters/SM_ACTION/conditions/washing"] = false
		player.anim_tree["parameters/SM_ACTION/conditions/chopping"] = false
	

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

	anim_tree["parameters/SM_Walking/conditions/empty"] = false
	anim_tree["parameters/SM_IDLE/conditions/empty"] = false
	anim_tree["parameters/SM_Walking/conditions/holding"] = true
	anim_tree["parameters/SM_IDLE/conditions/holding"] = true
	
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
	var item : Node3D = get_tree().current_scene.get_node_or_null(item_path)
	var player : Node3D = get_tree().current_scene.get_node_or_null(player_path)
	
	if(item == null):
		push_error("item invalid")
		return false
	
	if(!item.get_node("InteractableComponent").is_pickup):
		push_error("not pickup")
		return false
	
	if player.item_in_hand:
		player.rpc("server_drop_item", false)
	
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
	
	player.anim_tree["parameters/SM_Walking/conditions/empty"] = false
	player.anim_tree["parameters/SM_IDLE/conditions/empty"] = false
	player.anim_tree["parameters/SM_Walking/conditions/holding"] = true
	player.anim_tree["parameters/SM_IDLE/conditions/holding"] = true
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
	rpc("_client_drop_item", player_path, is_throw)
	return true


@rpc("any_peer", "call_local")
func _client_drop_item(player_path : String, is_throw : bool) -> bool:
	var player : Node3D = get_tree().current_scene.get_node(player_path)
	
	if player.item_in_hand && player.item_in_hand.is_in_group("Food"):
		player.item_in_hand.change_collisions(false)
	
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
	player.anim_tree["parameters/SM_Walking/conditions/empty"] = true
	player.anim_tree["parameters/SM_IDLE/conditions/empty"] = true
	player.anim_tree["parameters/SM_Walking/conditions/holding"] = false
	player.anim_tree["parameters/SM_IDLE/conditions/holding"] = false
	emit_signal("item_dropped", player.item_in_hand)
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
	emit_signal("item_dropped", item_in_hand)
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
			emit_signal("comp_hovered", _closest_item, false)
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
		if _closest_item : _closest_item.hover(false)
		emit_signal("comp_hovered", closest_item, true)
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
	await get_tree().process_frame
	
	var res = item_in_hand
	anim_tree["parameters/SM_Walking/conditions/empty"] = true
	anim_tree["parameters/SM_IDLE/conditions/empty"] = true
	anim_tree["parameters/SM_Walking/conditions/holding"] = false
	anim_tree["parameters/SM_IDLE/conditions/holding"] = false
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


func invert_controls(_invert : bool):
	if _invert: controller.vector = Input.get_vector("Up", "Down", "Right", "Left")
	if !_invert: controller.vector = Input.get_vector("Down", "Up", "Left", "Right")
	is_inverted = _invert


func disable_controls(_disable : bool, _action : bool):
	is_controls_disabled = _disable
	is_actoin_disabled = _action

func _can_app_interact() -> bool:
	if !_closest_item: return false
	
	var inter := _closest_item.get_parent()
	
	if !"current_owner" in inter: 
		return true

	return (inter.current_owner == ENetManager.get_my_team() || 
		  inter is Bench && !inter is ChopTable || 
		inter.current_owner == 0 || 
		inter is UpgradeHammer)
