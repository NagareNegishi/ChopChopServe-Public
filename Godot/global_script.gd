extends Node

var player : Player = null

func _ready() -> void:
	player = get_tree().get_current_scene().get_node("Player")
