class_name TeamSelect extends Area3D

@export var team : int
func _ready() -> void:
	body_entered.connect(_on_body_enter)


func _on_body_enter(body : Node3D):
	if !ENetManager.is_host() or body is not Player: return
	
	var player : Player = body
	var player_id = ENetManager.get_my_id()
	if player_id == -1: return
	ENetManager.enet_layer.send_to(1, {  # 1 is always the host
		"type": "request_team_join",
		"player_id": player_id,
		"team": team
	})
	print(ENetManager.get_my_team())
	player._server_set_name(player.name.to_int(),  GlobalScript.player_name)
