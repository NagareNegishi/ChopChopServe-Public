class_name Table extends Occupiable

@export var detection_area: Area3D
@export var current_plate: Plate = null
var dirty_plate =  preload("res://assets/newmodels/items/platedirt.glb")

func _ready():
	detection_area.body_entered.connect(_on_detection_area_body_entered)

func get_plate():
	return current_plate

## This function runs automatically whenever a physics body
## is above the table
func _on_detection_area_body_entered(body: Node3D):
	if not is_multiplayer_authority():
		return

	# Do nothing if the table is already occupied or the object isn't a plate.
	if current_plate != null or not body is Plate:
		return

	place_plate_rpc.rpc(body.get_path())

@rpc("any_peer", "call_local", "reliable")
func place_plate_rpc(plate_path: NodePath):
	var plate_node = get_node_or_null(plate_path)

	if is_instance_valid(plate_node):
		# if it's a valid plate and the table is empty, place it.
		current_plate = plate_node
		plate_node.reparent(self)
		plate_node.global_position = self.global_position + Vector3(0, 0.5, 0)
		plate_node.freeze = true

@rpc ("any_peer", "reliable")
func remove_plate():
	print(is_multiplayer_authority(), current_plate, "SHEEP")
	if current_plate:
		var food = current_plate.get_children().back()
		if food:
			food.queue_free()
