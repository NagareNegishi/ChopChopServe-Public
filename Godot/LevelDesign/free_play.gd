class_name FreePlay extends Node3D

@export var tut_mark : QuestionMark

func _ready() -> void:
	tut_mark.interact_comp.interacted.connect(_start_tutorial)
	multiplayer.peer_connected.connect(_name_fresh)


func _start_tutorial():
	pass

func _name_fresh(id : int):
	await get_tree().create_timer(0.2).timeout
	for player in GlobalScript.get_all_players():
		player.name_refresh.rpc()
