class_name NPC extends CharacterBody3D

# Constants for navigation
const SPEED: float = 4.0
const ACCELERATION: float = 100.0
const ANGULAR_ACCELERATION: float = 15.0
const PATHFINDING_DISTANCE_THRESHOLD: float = 0.1
const PATH_UPDATE_INTERVAL: float = 0.5  

# Provides agent to control NPC
@onready var _nav_agent = $NavigationAgent3D

var _game_server: Server # For communications with other services

# Agent's target information
var _current_target: Node3D = null
var _target_direction: Vector3 = Vector3.ZERO

# Helps to tell when to pause, stop or start pathfinding to a target
var _is_pathfinding: bool = false

var _agent_speed # Movement speed for agent
var _id # For unique indentification for other services

## Prepares navigation agent for movement
func _ready() -> void:
	var maps = NavigationServer3D.get_maps()
	_nav_agent.velocity_computed.connect(Callable(self, 
										"_on_navigation_agent_velocity_computed"))

func _on_navigation_agent_velocity_computed(safe_velocity: Vector3) -> void:
	_agent_speed = safe_velocity

## Ensures NPC moves as expected and uses its behavior
func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity += get_gravity() * delta
	if _is_pathfinding and _agent_speed != null:
		_movement(delta)
		_rotate_npc(delta)
		move_and_slide()
	_npc_behavior(delta)

## Moves NPC across plane
func _movement(delta: float) -> void:
		velocity.x = move_toward(velocity.x, _agent_speed.x, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, _agent_speed.z, ACCELERATION * delta)

## Ensures npc rotated to allign with movement towards target
func _rotate_npc(delta: float) -> void:
	if _target_direction.length() > 0 and has_node("Mesh"):
		$Mesh.rotation.y = lerp_angle($Mesh.rotation.y,
							atan2(_target_direction.x, _target_direction.z),
							delta * ANGULAR_ACCELERATION)

## Setter for agent's target direction
func set_direction(direction: Vector3) -> void:
	_target_direction = direction.normalized()
## Getter for agent's target direction
func get_direction() -> Vector3:
	return _target_direction

## Stops an NPC from pathfinding to target 
func stop_movement() -> void:
	_target_direction = Vector3.ZERO
	velocity.x = 0
	velocity.z = 0
	_is_pathfinding = false

## Should be overidden for unique pathing behavior
func _pathfind_to_target() -> void:
	assert(false, _id + "must have _pathfind_to_target() overridden")

## Should be overidden for unique pathing behavior
func _update_pathfinding(delta: float) -> void:
	assert(false, _id + "must have _update_pathfinding() overridden")

## Should be overidden for unique NPC behavior
func _npc_behavior(delta: float) -> void:
		assert(false, _id + "must have _npc_behavior() overridden")
	
