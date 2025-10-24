## appliance_highlight.gd
## Visual feedback component for appliances - shows glowing corners
## Automatically added as child to appliances and adapts to their size
class_name ApplianceHighlight
extends Node3D

enum HighlightState {
	HIDDEN,
	HOVER,
	ACCEPT,    # Can accept item (green)
	REJECT     # Cannot accept item (red)
}

# Fixed colors for different states
const COLORS = {
	HighlightState.HIDDEN: Color(0, 0, 0, 0),
	HighlightState.HOVER: Color(1.0, 1.0, 1.0, 0.6),
	HighlightState.ACCEPT: Color(0.0, 1.0, 0.0, 0.8),
	HighlightState.REJECT: Color(1.0, 0.0, 0.0, 0.8)
}

const CORNER_SIZE = 0.15  # Length of corner lines
const LINE_THICKNESS = 0.1  # Thickness of lines (actual 3D geometry)

var current_state: HighlightState = HighlightState.HIDDEN
var corner_meshes: Array[MeshInstance3D] = []
var material: StandardMaterial3D
var parent_appliance: Appliance

func _ready():
	parent_appliance = get_parent() as Appliance
	if not parent_appliance:
		push_error("ApplianceHighlight must be child of an Appliance")
		queue_free()
		return
	
	# Create glowing material
	material = preload("res://materials/InteractOverlay.tres")
	#material.albedo_color = COLORS[HighlightState.HIDDEN]
	#material.emission_enabled = true
	#material.emission = COLORS[HighlightState.HIDDEN]
	#material.emission_energy = 2.0
	#material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	#material.no_depth_test = false  # Respect depth - hide corners behind appliance
	#material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	#_create_corners()
	set_state(HighlightState.HIDDEN)

func _create_corners():
	var size = parent_appliance.size
	
	# 8 corner positions
	var corner_positions = [
		Vector3(-1, -1, -1), Vector3(1, -1, -1),  # Bottom corners
		Vector3(-1, -1, 1), Vector3(1, -1, 1),
		Vector3(-1, 1, -1), Vector3(1, 1, -1),    # Top corners
		Vector3(-1, 1, 1), Vector3(1, 1, 1)
	]
	
	for pos in corner_positions:
		var corner = _create_corner_mesh()
		corner.position = pos * (size * 0.5)
		
		# Scale corner to point inward
		corner.scale = Vector3(
			-sign(pos.x) if sign(pos.x) != 0 else 1,
			-sign(pos.y) if sign(pos.y) != 0 else 1,
			-sign(pos.z) if sign(pos.z) != 0 else 1
		)
		
		corner_meshes.append(corner)
		add_child(corner)

func _create_corner_mesh() -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	
	# X line
	var x_box = BoxMesh.new()
	x_box.size = Vector3(CORNER_SIZE, LINE_THICKNESS, LINE_THICKNESS)
	var x_mesh = MeshInstance3D.new()
	x_mesh.mesh = x_box
	x_mesh.position = Vector3(CORNER_SIZE * 0.5, 0, 0)
	x_mesh.material_override = material
	mesh_instance.add_child(x_mesh)
	
	# Y line
	var y_box = BoxMesh.new()
	y_box.size = Vector3(LINE_THICKNESS, CORNER_SIZE, LINE_THICKNESS)
	var y_mesh = MeshInstance3D.new()
	y_mesh.mesh = y_box
	y_mesh.position = Vector3(0, CORNER_SIZE * 0.5, 0)
	y_mesh.material_override = material
	mesh_instance.add_child(y_mesh)
	
	# Z line
	var z_box = BoxMesh.new()
	z_box.size = Vector3(LINE_THICKNESS, LINE_THICKNESS, CORNER_SIZE)
	var z_mesh = MeshInstance3D.new()
	z_mesh.mesh = z_box
	z_mesh.position = Vector3(0, 0, CORNER_SIZE * 0.5)
	z_mesh.material_override = material
	mesh_instance.add_child(z_mesh)
	
	return mesh_instance

func set_state(state: HighlightState):
	current_state = state
	#var color = COLORS[state]
	
	#if material:
		#material.albedo_color = color
		#material.emission = color
	visible = (state != HighlightState.HIDDEN)

func show_feedback(can_accept: bool):
	set_state(HighlightState.ACCEPT if can_accept else HighlightState.REJECT)

func hide_feedback():
	set_state(HighlightState.HIDDEN)
