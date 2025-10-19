class_name AbstractThrowable extends RigidBody3D

@onready var interact : InteractableComponent = $InteractableComponent



func _init() -> void:
	
	_store_original_transform()

## Connect to singal: Called when interacted with and will make the player pick this item up
## @return void
func _on_interactable_component_interacted():
	GlobalScript.get_local_player().rpc_id(1,"server_pickup", 
	GlobalScript.get_local_player().get_path(), self.get_path())
	for child in self.get_children():
		if child is MeshInstance3D:
			child.material_overlay = null
	
	print("Pickup: Interacted")


## Connected to signal: Called when player does action with this item in hand
## @param has_action if the player is using the action input
## @return void
func _on_interactable_component_action_use(is_action: bool) -> void:
	pass
	
func turnOnPhysics(is_on : bool):
	set_deferred("freeze", !is_on)


func _on_interactable_component_toggle_collision(turn_on: bool) -> void:
	for child in self.get_children():
		if child is CollisionShape3D:
			child.disabled = !turn_on
	$InteractableComponent/CollisionShape3D.disabled = !turn_on



var original_transform: Transform3D
var original_scale: Vector3


func _store_original_transform():
	# Store the main object's transform/scale
	original_transform = transform
	original_scale = scale
	
	
	print("Original transforms stored for ", get_class())

func restore_original_transform():
	# Restore main object
	transform = original_transform
	scale = original_scale


## Rotate the throwable object by a given angle
## @param angle: The angle to rotate
func rotate_abstract_throwable(angle: Vector3):
	global_rotation += angle
