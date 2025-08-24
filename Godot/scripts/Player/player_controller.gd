class_name PlayerController
extends MultiplayerSynchronizer

@onready var input_dir : Vector2

func _process(delta: float) -> void:
	input_dir = Input.get_vector("Up", "Down", "Right", "Left")
