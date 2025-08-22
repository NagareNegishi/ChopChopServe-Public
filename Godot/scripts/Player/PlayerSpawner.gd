class_name PlayerSpawner
extends MultiplayerSpawner

@export var network_player : PackedScene

func _ready() -> void:
	multiplayer.peer_connected.connect(_spawn_player)
	if multiplayer.is_server():
		_spawn_player(multiplayer.get_unique_id())

func _spawn_player(id : int):
	if !multiplayer.is_server() : return
	
	var player : Node = network_player.instantiate()
	player.name = str(id)
	get_node(spawn_path).call_deferred("add_child", player)
