class_name Table extends Occupiable

@export var detection_area: Area3D
@export var current_plate: Plate = null
var dirty_plate =  preload("res://assets/newmodels/items/platedirt.glb")
var plates = []
func _ready():
	detection_area.area_entered.connect(_on_detection_area_area_entered)
	detection_area.area_exited.connect(_on_detection_area_area_exited)
func get_plate():
	return current_plate


## This function runs automatically whenever a physics body
## is above the table
func _on_detection_area_area_entered(area: Node3D):
	if not is_multiplayer_authority():
		return
	var area_parent = area.get_parent()
	print(area_parent is Plate, "WWW")
	if area_parent is Plate and not (area_parent in plates):
		print("IM A PLATE")
		plates.append(area_parent)

func _process(delta):
	if current_plate:
		return
	for plate in plates:
		if not (plate.get_parent() is Player):
			print("IM A PLATE")
			place_plate_rpc.rpc(plate.get_path())
			current_plate = plate
func _on_detection_area_area_exited(area: Node3D):
	var area_parent = area.get_parent()
	if area_parent is Plate and area_parent in plates:
		plates.erase(area_parent)
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
