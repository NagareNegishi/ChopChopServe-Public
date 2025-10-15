class_name HUD
extends Control


@export var game_state : GameStateTest 

@onready var game_state_ui : UIGameState = $UIGameState
@onready var debug_hud = [$Controls, $FPS, $Server]
@onready var sabotage_nodes = [$Sabotages/UiSabotageNode, $Sabotages/UiSabotageNode2, 
$Sabotages/UiSabotageNode3, $Sabotages/UiSabotageNode4, 
$Sabotages/UiSabotageNode5, $Sabotages/UiSabotageNode6]

func _ready() -> void:
	$Server.text = "Client" if !multiplayer.is_server() else "Server"

	for control in debug_hud:
		control.visible = false
	
	game_state_ui.game_state = game_state
	SabotageSystem.sabotage_start.connect(sabotage_start)
	
func _process(delta: float) -> void:
	var fps = Engine.get_frames_per_second()
	$FPS.text = str(fps) + " FPS"
	if Input.is_action_just_pressed("DEBUG"):
		_toggle_debug_controls()

func _toggle_debug_controls():
	for control in debug_hud:
		control.visible = !control.visible


func sabotage_popup(time : float ):
	pass

func sabotage_start(teamID: int, sab_name: String, sab_time: int):
	if teamID == ENetManager.get_my_team(): return
	
