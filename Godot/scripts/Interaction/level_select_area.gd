extends Area3D

@export var level : SceneManager.Scene

func _ready() -> void:
	connect("area_entered", _area_entered)

func _area_entered():
	SceneManager.change_scene_all_players(level)
