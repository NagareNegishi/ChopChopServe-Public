class_name PlayerSpawner
extends MultiplayerSpawner

const RUN : bool = false

@export var spawns : Array[SpawnPoint]
@export var network_player : PackedScene


## Called when the node enters the scene tree for the first time.
## @return void
func _ready() -> void:
	if !RUN: return
	
	multiplayer.peer_connected.connect(_spawn_player)

	if multiplayer.is_server():
		_spawn_player(multiplayer.get_unique_id())


## Spawns player, automatically replicated
## @param int the id of the peer
## @return void
func _spawn_player(id : int):
	if !multiplayer.is_server() : return

	var spawn_point : SpawnPoint = _get_spawn_point()
	
	var player : Player = network_player.instantiate()
	
	player.name = str(id)
	player.set_multiplayer_authority(id)
	get_node(spawn_path).call_deferred("add_child", player)
	rpc("_set_position", id, spawn_point.position)


## Calls a deffered function to apply posistion to player
## @param int the peer id
## @param spawn_point the location where the player is spawning
## @return void
@rpc("authority", "call_local", "reliable")
func _set_position(player_id : int, spawn_point : Vector3):
	call_deferred("_apply_position", player_id, spawn_point)


## Applies position to the player
## @param int the peer id
## @param spawn_point the location where the player is spawning
## @return void
func _apply_position(player_id : int, spawn_point : Vector3):
	var player = get_tree().current_scene.get_node("== PLAYERS ==/" + str(player_id))
	if player:
		player.position = spawn_point


## Finds a valid spawn point for the player to spawn at
## @return void
func _get_spawn_point() -> SpawnPoint:
	#Filters all active spawn points
	var valid_spawns = spawns.filter(func(_spawn : SpawnPoint) : return _spawn.is_active())
	
	if valid_spawns.size() <= 0:
		return null
		
	var index : int = randi() % valid_spawns.size()
	valid_spawns.get(index).use()
	return valid_spawns.get(index)
