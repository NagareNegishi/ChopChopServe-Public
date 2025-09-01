## Base class for all placeable objects in the kitchen
## Handles positioning, size, and collision detection
class_name Placeable
extends RigidBody3D

enum Direction {
	NORTH = 0,
	EAST = 1,
	SOUTH = 2,
	WEST = 3
}

## Collision layer constants for now!!!!!!!! we should define and share in some global file
const FLOORS = 1
const PLAYERS = 2
const APPLIANCES = 4

@export_group("Placeable Settings")
## Check collisions against these layers to prevent invalid placement
@export var collide_with: int = FLOORS + PLAYERS + APPLIANCES
## Visual appearance of the placeable object
@export var model_scene: PackedScene
## Physical dimensions of the placeable object
@export var size: Vector3 = Vector3(1.0, 1.0, 1.0): set = set_size # automatically call set_size when changed
## Scale factor for interaction area size
@export var interaction_scale: float = 1.0
## Default facing direction
@export var default_facing: Direction = Direction.NORTH


var can_move: bool = true
var facing_direction: Direction
var model_instance: Node3D
var collision_shape: CollisionShape3D  # For physics
var interaction_area: Area3D  # For detection
var interaction_shape: CollisionShape3D
var multiplayer_sync: MultiplayerSynchronizer
var initialized: bool = false


## Initialize the placeable with specific dimensions
## @param width: Size along X-axis
## @param height: Size along Y-axis
## @param depth: Size along Z-axis
func _init(width: float = 1.0, height: float = 1.0, depth: float = 1.0):
	size = Vector3(width, height, depth)


## Called when the node is added to the scene tree
func _ready():
	facing_direction = default_facing
	setup_children()
	# physics setup
	gravity_scale = 1.0
	mass = 1.0
	lock_rotation = true
	setup_collision()
	setup_model()
	setup_multiplayer_sync()
	# Configure interaction area, no collide but detect overlaps
	interaction_area.collision_layer = 0
	interaction_area.monitoring = true
	interaction_area.area_entered.connect(_on_area_entered)
	interaction_area.area_exited.connect(_on_area_exited)
	initialized = true
#----------------------------------------
	lock()
	# print_sync_properties()
	_store_original_transform()       # should be removed once player returns original scale !!!
#----------------------------------------


## Create required child nodes
func setup_children():
	if not has_node("CollisionShape3D"):
		collision_shape = CollisionShape3D.new()
		collision_shape.name = "CollisionShape3D"
		add_child(collision_shape)
	else:
		collision_shape = $CollisionShape3D
	if not has_node("InteractionArea"):
		interaction_area = Area3D.new()
		interaction_area.name = "InteractionArea"
		add_child(interaction_area)
		interaction_shape = CollisionShape3D.new()
		interaction_shape.name = "CollisionShape3D"
		interaction_area.add_child(interaction_shape)
	else:
		interaction_area = $InteractionArea
		interaction_shape = $InteractionArea/CollisionShape3D
	if not has_node("MultiplayerSynchronizer"):
		multiplayer_sync = MultiplayerSynchronizer.new()
		multiplayer_sync.name = "MultiplayerSynchronizer"
		add_child(multiplayer_sync)
	else:
		multiplayer_sync = $MultiplayerSynchronizer


## Initialize collision shape based on size
func setup_collision():
	collision_layer = 1   #APPLIANCES     !!!! use floor until the team sort collision layer!!!!
	collision_mask = 1  #collide_with
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


# Setup the model instance from the assigned PackedScene
func setup_model():
	# If concrete class has a instance of model as child, use it (for someone use .tscn)
	for child in get_children():
		if child.scene_file_path.ends_with(".glb"):
			model_instance = child
			align_to_model()
			return

	# otherwise, instantiate the model scene and align it
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
	align_to_model()
	add_child(model_instance)


## Setup multiplayer synchronization, if not already set up
func setup_multiplayer_sync():
	if multiplayer_sync:
		if not multiplayer_sync.replication_config:
			var config = SceneReplicationConfig.new()
			config.add_property(NodePath(".:position"))
			config.add_property(NodePath(".:rotation"))
			config.add_property(NodePath(".:size"))
			multiplayer_sync.replication_config = config


## Align the size of the Placeable to the model
func align_to_model():
	if not model_instance:
		return
	for child in model_instance.get_children():
		if child is MeshInstance3D:
			var aabb = child.get_aabb()
			if aabb.size != Vector3.ZERO:
				# Account for model's transform
				var model_aabb = child.transform * aabb
				set_size(model_aabb.size)
				model_instance.position = -model_aabb.get_center()
				return
	push_error("No valid AABB found")


## Resize the model to match the Placeable
func resize_model():
	if not model_instance:
		return
	# Get current model size
	var current_size = Vector3.ZERO
	for child in model_instance.get_children():
		if child is MeshInstance3D:
			var aabb = child.get_aabb()
			current_size = (child.transform * aabb).size
			break

	if current_size != Vector3.ZERO:
		var scale_factor = size / current_size
		model_instance.scale = scale_factor
		model_instance.position = Vector3.ZERO # Keep model centered


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
	if initialized:
		resize_model()


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


## Rotate the placeable to face a specific direction
func rotate_to_direction(new_direction: Direction) -> bool:
	var target_angle = new_direction * PI/2
	var angle_diff = target_angle - rotation.y
	if rotate_by(angle_diff):
		facing_direction = new_direction
		return true
	return false


## Virtual method - override in subclasses
## @param area: The area that entered
func _on_area_entered(_area: Area3D):
	pass # Override in subclasses


## Virtual method - override in subclasses
## @param area: The area that exited
func _on_area_exited(_area: Area3D):
	pass # Override in subclasses


## Print the synchronized properties (For debugging)
func print_sync_properties():
	if multiplayer_sync and multiplayer_sync.replication_config:
		var config = multiplayer_sync.replication_config
		print("=== Configured Sync Properties ===")
		var properties = config.get_properties()
		print("Number of properties: ", properties.size())
		for i in range(properties.size()):
			var property = properties[i]
			print("Property ", i, ": ", property)


# External additions------------------------------------------------------------
## Toggle physics state - requires documentation from original author
func turnOnPhysics(is_on : bool):
	set_deferred("freeze", !is_on)
#-------------------------------------------------------------------------------



#-------------------------------------------------------------------------------
# This part should be remove for better performance
# this is fallback code for if player can not return placeable as original transform

var original_transform: Transform3D
var original_scale: Vector3
var original_model_transform: Transform3D
var original_model_scale: Vector3

func _store_original_transform():
	# Store the main object's transform/scale
	original_transform = transform
	original_scale = scale
	
	# Store model's transform/scale if it exists
	if model_instance:
		original_model_transform = model_instance.transform
		original_model_scale = model_instance.scale
	
	# print("Original transforms stored for ", get_class())

func restore_original_transform():
	# Restore main object
	transform = original_transform
	scale = original_scale
	
	# Restore model if it exists
	if model_instance:
		model_instance.transform = original_model_transform
		model_instance.scale = original_model_scale
	
	# print("All transforms restored for ", get_class())

#-------------------------------------------------------------------------------