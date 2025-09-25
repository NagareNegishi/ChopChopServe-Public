class_name AbstractThrowable extends RigidBody3D

var overlay = preload("res://materials/InteractOverlay.tres")

## Called when the node enters the scene tree for the first time.
## @return void
func _enter_tree() -> void:
	pass


## Called every frame. 'delta' is the elapsed time since the previous frame.
## @param delta elapsed time since the previous frame
## @return void
func _process(_delta: float) -> void:
	pass


func _ready() -> void:
	var interact : InteractableComponent = $InteractableComponent
	

## Connect to singal: Called when interacted with and will make the player pick this item up
## @return void
func _on_interactable_component_interacted():
	GlobalScript.get_local_player().rpc_id(1,"server_pickup", 
	GlobalScript.get_local_player().get_path(), self.get_path())
	for child in self.get_children():
		if child is MeshInstance3D:
			child.material_overlay = null
	
	print("Pickup: Interacted")


## Connected to signal: Called when pickup is being hovered or unhovered
## @param is_hovered boolean that dicates if pickup is on or off
## @return void
func _on_interactable_component_hovered(is_hovered: bool) -> void:
	for child in self.get_children():
		if child is MeshInstance3D:
			child.material_overlay = overlay if is_hovered else null

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
