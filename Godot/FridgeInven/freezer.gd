extends RigidBody3D

var inventory_instance = null

func _on_area_3d_body_entered(body):
	if body is Player and body.name.to_int() == ENetManager.get_my_id():
		if inventory_instance == null:
			inventory_instance = $Inventory
		inventory_instance.open()


func _on_area_3d_body_exited(body):
	if body is Player and body == GlobalScript.get_local_player():
		inventory_instance.close()
