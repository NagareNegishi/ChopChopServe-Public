@tool
class_name LevelName extends Control

@export var level_name : String : 
	get: return _level_name
	set(text): _set_text(text)

var _level_name : String = "[Deault]"

func _set_text(n_name : String):
	_level_name = n_name
	$Label.text = n_name
