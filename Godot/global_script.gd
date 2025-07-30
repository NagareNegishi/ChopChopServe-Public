extends Node

var player : Player

## Called when the node enters the scene tree for the first time.
## @return void
func _ready() -> void:
	player = get_tree().get_current_scene().get_node("Player")
