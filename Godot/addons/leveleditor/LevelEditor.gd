@tool
extends EditorPlugin

var dock_scene_preload = preload("res://addons/leveleditor/UI_LevelEditor.tscn")
var dock_scene

func _enter_tree() -> void:
	dock_scene = dock_scene_preload.instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, dock_scene) # Example: add to bottom-left dock
	pass


func _exit_tree() -> void:
	remove_control_from_docks(dock_scene)
	dock_scene.queue_free()
	pass
