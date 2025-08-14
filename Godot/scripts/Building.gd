class_name Building extends MeshInstance3D

# How many units apart objects should appear on grid
const GRID_UNIT: float = 0.5 

# How often grid snapping will occur
const SNAP_INTERVAL: float = 0.02

var _game_server: Server # For communications with other services

# Position information for grid snapping
var _safe_position: Vector3 = self.position
var _test_position: Vector3 = self.position
var _build_height: float = 0

# To reduce redudant snap calls when world hasn't changed
var _last_snap_time: float = 0.0

# For checking collisions
var _collision_clone
var _is_collision_clone: bool = false

# Mainly used for informing mouse position in scene
var _camera : Camera3D

# Simplfied reference for collider
@onready var collider = $Area3D

## Ensures server can be referenced
func _init(server = null):
	if server != null:
		_game_server = server

## Checks for Rigidbody3D or Area3D overlaps with self
func overlaps():
	return collider.get_overlapping_bodies() + collider.get_overlapping_areas()

## Provides clone for checking overlaps when testing grid snapping	
func produce_collision_clone():
	_collision_clone = duplicate()
	_collision_clone._is_collision_clone = true
	_collision_clone.hide()
	get_parent().add_child(_collision_clone)

## Changes material and removes script to prevent further moving
func place_building():
	self.set_script(null)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.GREEN
	set_surface_override_material(0, mat)

## Uses mouse inputs to move building and decide its placement
func _input(event):
	if !_is_collision_clone: # clones should not respond to inputs
		if !_collision_clone: 
			produce_collision_clone() 
			_camera = get_viewport().get_camera_3d()
		if event is InputEventMouseMotion:
			update_position_from_mouse()
			snap_to_grid()
			
		elif event is InputEventMouseButton && event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				_build_height += GRID_UNIT
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				_build_height -= GRID_UNIT	
			elif event.button_index == MOUSE_BUTTON_MIDDLE:
				place_building()
				
## Finds where mouse bests fits in 3d space and saves position
func update_position_from_mouse():
	var mouse_position_2d = get_viewport().get_mouse_position()
	var drop_plane = Plane(Vector3(0, 1, 0), _build_height)
	var ray_origin = _camera.project_ray_origin(mouse_position_2d)
	var ray_normal = _camera.project_ray_normal(mouse_position_2d)
	
	var intersection_point = drop_plane.intersects_ray(ray_origin, ray_normal)
	if intersection_point != null:
		if (position != (intersection_point /GRID_UNIT).floor() * GRID_UNIT):
			_test_position = intersection_point
		
## Snaps building's position onto a new grid position if space is clear
func snap_to_grid():
	var original_pos = _test_position 
	var target_position = (original_pos / GRID_UNIT).floor() * GRID_UNIT
	_collision_clone.position = target_position
	
	# ensures overlaps aren't missed
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Tweens building to new grid position if no overlaps are found 
	var overlaps = _collision_clone.overlaps()
	if overlaps.is_empty() || (overlaps.size() == 1 && overlaps[0] == collider):
		_safe_position = target_position
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "position", target_position, 0.5)
	else:
		position = _safe_position

		
		
	
