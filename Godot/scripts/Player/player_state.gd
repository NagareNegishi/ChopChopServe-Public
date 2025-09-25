class_name PlayerState
extends Node

var player_name : String

#============= NAME ===================


func set_player_name(n : String):
	rpc_id(1, "_server_set_name", n)


func _server_set_name(n : String):
	rpc("_client_set_name", n)


func _client_set_name(n : String):
	player_name = n

func _to_string() -> String:
	return "[%s]" % [player_name]
