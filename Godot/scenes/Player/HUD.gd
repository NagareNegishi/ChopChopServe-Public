class_name HUD
extends Control

func _process(delta: float) -> void:
	var fps = Engine.get_frames_per_second()
	$FPS.text = str(fps) + " FPS"
