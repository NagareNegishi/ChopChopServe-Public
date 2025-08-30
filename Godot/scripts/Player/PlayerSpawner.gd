class_name PlayerSpawner
extends MultiplayerSpawner

const RUN : bool = false
@export var spawns : Array[SpawnPoint]
@export var network_player : PackedScene

func _ready() -> void:
	if !RUN: return
	multiplayer.peer_connected.connect(_spawn_player)
	if multiplayer.is_server():
		_spawn_player(multiplayer.get_unique_id())

func _spawn_player(id : int):
	if !multiplayer.is_server() : return

	var spawn_point : SpawnPoint = get_spawn_point()
	
	var player : Player = network_player.instantiate()
	
	player.name = str(id)

	get_node(spawn_path).call_deferred("add_child", player)

	
@rpc("call_local")
func _set_position(player_id : int, spawn_point : Vector3):
	get_tree().get_current_scene().get_node(str(player_id)).position = spawn_point
	
func get_spawn_point() -> SpawnPoint:
	var valid_spawns = spawns.filter(func(_spawn : SpawnPoint) : return _spawn.is_active())
	
	if valid_spawns.size() <= 0:
		return null
		
	var index : int = randi() % valid_spawns.size()
	valid_spawns.get(index).use()
	return valid_spawns.get(index)
