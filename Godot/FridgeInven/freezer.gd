extends RigidBody3D

var inventory_instance = null



func _on_area_3d_body_entered(body):
	if body is Player:
		if inventory_instance == null:
			inventory_instance = $Inventory
		inventory_instance.open()


func _on_area_3d_body_exited(body):
	if body is Player:
		inventory_instance.close()
