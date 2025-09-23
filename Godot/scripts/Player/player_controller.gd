class_name PlayerController
extends MultiplayerSynchronizer

@onready var input_dir : Vector2
var vector : Vector2
	
func _process(delta: float) -> void:
	input_dir = vector
