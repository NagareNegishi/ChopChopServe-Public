class_name AbstractPickup extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_interactable_component_interacted() -> void:
	get_tree().get_current_scene().get_node("Player").pickup_item(self)
	print("Pickup: Interacted")
	
func turn_on_collision(turn_on: bool) -> void:
	$StaticBody3D/CollisionShape3D.disabled = !turn_on
	$InteractableComponent/CollisionShape3D.disabled = !turn_on
