class_name FreePlay extends Node3D

@export var tut_mark : QuestionMark
@export var hud : HUBHud

func _ready() -> void:
	tut_mark.tutorial.connect(_start_tutorial)
	multiplayer.peer_connected.connect(_name_fresh)
	hud.set_tutorial_vis(false)


func _start_tutorial(started : bool):
	hud.set_tutorial_vis(started)

func _name_fresh(id : int):
	await get_tree().create_timer(0.2).timeout
	for player in GlobalScript.get_all_players():
		player.name_refresh.rpc()
