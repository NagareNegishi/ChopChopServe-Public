class_name Table extends Occupiable

@export var detection_area: Area3D
@export var current_plate: Plate = null

var plate_in_area: Plate = null
func get_plate():
	return current_plate
func _process(delta):
	if current_plate == null and Input.is_action_just_pressed("Interact"):
		await get_tree().physics_frame
		await get_tree().physics_frame
		for body in detection_area.get_overlapping_bodies():
			if body is Plate:
				add_plate(body)
				break

func add_plate(plate_to_add: Plate):
	if current_plate != null:
		return

	GlobalScript.player.drop_item(false)
	current_plate = plate_to_add
	plate_to_add.reparent(self)
	plate_to_add.global_position = self.global_position + Vector3(0, 0.5, 0)
	plate_to_add.freeze = true
func remove_plate():
	remove_child(current_plate)
	current_plate.queue_free()
	current_plate = null
