## Base class for all placeable objects in the kitchen
## Handles positioning, size, and collision detection
class_name Placeable
extends RigidBody3D

## Collision layer constants for now!!!!!!!! we should define and share in some global file
const FLOORS = 1
const PLAYERS = 2
const APPLIANCES = 4

## Check collisions against these layers to prevent invalid placement
@export var collide_with: int = FLOORS + PLAYERS + APPLIANCES
## Visual appearance of the placeable object
@export var model_scene: PackedScene
## Physical dimensions of the placeable object
@export var size: Vector3 = Vector3(1.0, 1.0, 1.0): set = set_size # automatically call set_size when changed
## Scale factor for interaction area size
@export var interaction_scale: float = 1.0

var can_move: bool = true
var model_instance: Node3D

## Reference to collision detection area
@onready var collision_shape: CollisionShape3D = $CollisionShape3D  # For physics
@onready var interaction_area: Area3D = $InteractionArea  # For detection
@onready var interaction_shape: CollisionShape3D = $InteractionArea/CollisionShape3D


## Initialize the placeable with specific dimensions
## @param width: Size along X-axis
## @param height: Size along Y-axis
## @param depth: Size along Z-axis
func _init(width: float = 1.0, height: float = 1.0, depth: float = 1.0):
	size = Vector3(width, height, depth)


## Called when the node is added to the scene tree
func _ready():
	# physics setup
	gravity_scale = 1.0
	mass = 1.0
	lock_rotation = true
	setup_collision()
	setup_model()
	# Configure interaction area, no collide but detect overlaps
	interaction_area.collision_layer = 0
	interaction_area.monitoring = true
	interaction_area.area_entered.connect(_on_area_entered)
	interaction_area.area_exited.connect(_on_area_exited)


## Initialize collision shape based on size
func setup_collision():
	collision_layer = APPLIANCES
	collision_mask = collide_with
	# Setup physics collision shape
	if collision_shape:
		var shape = BoxShape3D.new()
		shape.size = size
		collision_shape.shape = shape
	# Setup interaction area shape
	if interaction_shape:
		var interaction_box = BoxShape3D.new()
		interaction_box.size = size * interaction_scale
		interaction_shape.shape = interaction_box


## Setup the model instance from the assigned PackedScene
func setup_model():
	if not model_scene:
		push_warning("No model assigned to " + name)
		return
	if not model_scene.can_instantiate():
		push_error("Cannot instantiate model scene for " + name)
		return
	model_instance = model_scene.instantiate()
	if not model_instance:
		push_error("Failed to instantiate model for " + name)
		return
	align_model()
	add_child(model_instance)


## Align the model and Placeable
## Placeable's size is defined by the model's AABB
## but position is defined by the Placeable
func align_model():
	if not model_instance:
		return
	for child in model_instance.get_children():
		if child is MeshInstance3D:
			var aabb = child.get_aabb()
			if aabb.size != Vector3.ZERO:
				# Account for node scaling
				var actual_size = aabb.size * child.scale
				var aabb_center = aabb.get_center() * child.scale
				set_size(actual_size)
				model_instance.position = -aabb_center
				return
	push_error("No valid AABB found")


## Update size and automatically refresh collision shape
## @param new_size: New dimensions for the placeable object
func set_size(new_size: Vector3):
	size = new_size
	# Update physics collision shape
	if collision_shape and collision_shape.shape:
		collision_shape.shape.size = size
	# Update interaction area shape
	if interaction_shape and interaction_shape.shape:
		interaction_shape.shape.size = size


## Add layers to the collision mask
## @param layers_to_add: Bitmask of layers to add
func add_collision_layers(layers_to_add: int):
	collision_mask |= layers_to_add
	collide_with |= layers_to_add


## Remove layers from the collision mask
## @param layers_to_remove: Bitmask of layers to remove
func remove_collision_layers(layers_to_remove: int):
	collision_mask &= ~layers_to_remove
	collide_with &= ~layers_to_remove


## Get the bounding box of this placeable object
## @return: AABB representing the object's bounds in world space
func get_bounds() -> AABB:
	var bounds = AABB(global_position - size / 2, size)
	return bounds


## Lock the object in place (prevent movement and rotation)
func lock():
	can_move = false
	freeze = true


## Unlock the object (allow movement and rotation)
func unlock():
	can_move = true
	freeze = false


## Check if object is currently locked
## @return: True if locked (cannot move/rotate)
func is_locked() -> bool:
	return not can_move


## Check if this object can be placed at the given position
## @param target_position: World position to check
## @return: True if placement is valid
func can_place_at(target_position: Vector3) -> bool:
	# NOTE: if subclass call it frequently, consider make them class variable
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state # Get physics world
	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new() # List of instructions
	
	# Reuse existing collision shape if available
	if collision_shape and collision_shape.shape:
		query.shape = collision_shape.shape
	else:
		var box_shape: BoxShape3D = BoxShape3D.new()
		box_shape.size = size
		query.shape = box_shape
	
	query.transform.origin = target_position
	query.collision_mask = collision_mask
	
	# Check for collisions on specified layers only
	var collisions: Array[Dictionary] = space_state.intersect_shape(query)
	return collisions.is_empty()


## Place the object at the specified position
## @param target_position: Where to place the object
## @return: True if placement was successful
func place_at(target_position: Vector3) -> bool:
	if can_place_at(target_position):
		freeze = true
		global_position = target_position
		freeze = false
		return true
	return false


## Move the placeable to a new position if valid
## @param target_position: Where to move the object
## @return: True if move was successful
func move_to(target_position: Vector3) -> bool:
	if not can_move:
		return false
	if can_place_at(target_position):
		freeze = true
		global_position = target_position
		freeze = false
		return true
	return false


## Move the placeable by an offset from current position
## @param offset: Vector3 offset to move by
## @return: True if move was successful
func move_by(offset: Vector3) -> bool:
	if not can_move:
		return false
	return move_to(global_position + offset)


## Rotate the placeable object by the given angle, if possible
## @param angle: Relative rotation angle in radians
## @return: True if rotation is valid
func rotate_by(angle: float) -> bool:
	if not can_move:
		return false
	var old_angle = rotation.y
	rotation.y += angle
	if not can_place_at(global_position):
		rotation.y = old_angle
		return false
	return true


## Virtual method - override in subclasses
## @param area: The area that entered
func _on_area_entered(_area: Area3D):
	pass # Override in subclasses


## Virtual method - override in subclasses
## @param area: The area that exited
func _on_area_exited(_area: Area3D):
	pass # Override in subclasses
