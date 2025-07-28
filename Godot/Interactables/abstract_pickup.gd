class_name AbstractPickup extends Node3D

@export var has_action : bool


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_interactable_component_interacted() -> void:
	GlobalScript.player.pickup_item(self)
	print("Pickup: Interacted")
	
func turn_on_collision(turn_on: bool) -> void:
	$StaticBody3D/CollisionShape3D.disabled = !turn_on
	$InteractableComponent/CollisionShape3D.disabled = !turn_on


func _on_interactable_component_hovered(is_hovered: bool) -> void:
	if is_hovered:
		print("Hovered: " + str(self))


func _on_interactable_component_action_use(is_action: bool) -> void:
	if has_action:
		print("Action: " + str(is_action))
