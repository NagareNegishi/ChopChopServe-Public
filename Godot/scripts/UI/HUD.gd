class_name HUD
extends Control


@export var game_state : GameStateTest 

@onready var game_state_ui : UIGameState = $UIGameState
@onready var debug_hud = [$Controls, $FPS, $Server]
@onready var sabotage_nodes = [$Sabotages/UiSabotageNode, $Sabotages/UiSabotageNode2, 
$Sabotages/UiSabotageNode3, $Sabotages/UiSabotageNode4, 
$Sabotages/UiSabotageNode5, $Sabotages/UiSabotageNode6]


@onready var node_focus : UISabotageNode = $Sabotages/UiSabotageNode
func _ready() -> void:
	$Server.text = "Client" if !multiplayer.is_server() else "Server"
	for control in debug_hud:
		control.visible = false
	
	game_state_ui.game_state = game_state
	
	SabotageSystem.sabotage_start.connect(sabotage_start)
	Input.joy_connection_changed.connect(_cont)
	await get_tree().create_timer(0.2).timeout
	_cont(0, Input.get_connected_joypads().size() >=1)
	
func _process(delta: float) -> void:
	var fps = Engine.get_frames_per_second()
	$FPS.text = str(fps) + " FPS"
	if Input.is_action_just_pressed("DEBUG"):
		_toggle_debug_controls()


	
func _toggle_debug_controls():
	for control in debug_hud:
		control.visible = !control.visible


func sabotage_start(teamID: int, sab_name: String, sab_time: int):
	if teamID == ENetManager.get_my_team(): return
	
func _cont(d : int, c : bool):
	for n in sabotage_nodes: n.hide_(0, c)
	if !c: 
		move(-1)
		GlobalScript.get_local_player().sabo_move.disconnect(move)
	
		return
	GlobalScript.get_local_player().sabo_move.connect(move)
	curr_idx = GlobalScript.get_local_player().sabo_index
	move(curr_idx)
	
var curr_idx = 0
func move(i : int):
	if i == -1:
		sabotage_nodes[curr_idx]._unhovered()
		curr_idx = -1
		return
	sabotage_nodes[curr_idx]._unhovered()
	sabotage_nodes[i]._hovered()
	curr_idx = i
