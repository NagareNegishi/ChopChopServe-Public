class_name Table extends Occupiable

@export var detection_area: Area3D
@export var current_plate: Plate = null

func _ready():
	detection_area.body_entered.connect(_on_detection_area_body_entered)

func get_plate():
	return current_plate

## This function runs automatically whenever a physics body
## is above the table
func _on_detection_area_body_entered(body: Node3D):
	# Do nothing if the table is already occupied or the object isn't a plate.
	if current_plate != null or not body is Plate:
		return

	# if it's a valid plate and the table is empty, place it.
	current_plate = body
	body.reparent(self)
	body.global_position = self.global_position + Vector3(0, 0.5, 0)
	body.freeze = true
@rpc ("any_peer", "call_local", "reliable")
func remove_plate():
	if current_plate:
		remove_child(current_plate)
		current_plate.queue_free()
		current_plate = null
