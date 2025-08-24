extends Control

func _ready() -> void:
	$Server.text = "Client" if !multiplayer.is_server() else "Server"
