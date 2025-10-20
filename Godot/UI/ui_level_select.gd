class_name LevelName extends Control

@export var label : Label
@export var level_name : String

func _set_text(n_name : String):
	label.text = n_name

func _ready() -> void:
	_set_text(level_name)
