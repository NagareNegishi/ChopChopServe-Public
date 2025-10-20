class_name StartGame extends Area3D

var players : Array[Player] = []
func _ready() -> void:
	body_entered.connect(_on_body_enter)


func _on_body_enter(body : Node3D):
	if !ENetManager.is_host() or body is not Player: return
	
	var player : Player = body
	if players.has(player): return
	players.append(player)
	
	if !players.size() == ENetManager.player_list.size(): return
	
	SceneManager.change_scene_all_players(SceneManager.Scene.LOBBY)
