extends Control

@onready var list : Array[Control] = [$PlayerList/P1, $PlayerList/P2, $PlayerList/P3, $PlayerList/P4]

func _ready() -> void:
	$Server.text = "Client" if !multiplayer.is_server() else "Server"
	_load_players()

func _load_players():
	var players := ENetManager.get_player_list()
	for i in range(list.size()):
		if i >= players.size(): 
			list[i].queue_free()
			continue
		
		list[i].get_node("Player").set_from_id(players[i])
		
