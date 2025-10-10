class_name HUD
extends Control

@onready var debug_hud = [$Controls, $FPS, $Server]
@export var game_state : GameStateTest 
@onready var game_state_ui : UIGameState = $UIGameState

func _ready() -> void:
	$Server.text = "Client" if !multiplayer.is_server() else "Server"

	for control in debug_hud:
		control.visible = true
	
	game_state_ui.game_state = game_state
	
func _process(delta: float) -> void:
	var fps = Engine.get_frames_per_second()
	$FPS.text = str(fps) + " FPS"
	if Input.is_action_just_pressed("DEBUG"):
		_toggle_debug_controls()

func _toggle_debug_controls():
	for control in debug_hud:
		control.visible = !control.visible
