class_name PlayerCarController
extends MultiplayerSynchronizer

@export var input_direction : Vector2

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	input_direction = Vector2.ZERO
	input_direction.x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	input_direction.y = Input.get_action_strength("Down") - Input.get_action_strength("Up")
	
	
