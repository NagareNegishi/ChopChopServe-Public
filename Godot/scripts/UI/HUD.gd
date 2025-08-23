class_name HUD
extends Control


func _ready() -> void:
	$Controls.visible = false
	
func _process(delta: float) -> void:
	var fps = Engine.get_frames_per_second()
	$FPS.text = str(fps) + " FPS"
	if Input.is_action_just_pressed("DEBUG"):
		_toggle_debug_controls()

func _toggle_debug_controls():
	$Controls.visible = !$Controls.visible
