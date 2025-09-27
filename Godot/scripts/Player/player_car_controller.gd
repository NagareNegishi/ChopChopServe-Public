class_name PlayerCarController
extends MultiplayerSynchronizer

@onready var move_input : int
@onready var turn_input : int


func _process(delta: float) -> void:
	if ENetManager.get_my_id() != multiplayer.get_unique_id(): return
	
	move_input = 0
	turn_input = 0
	
	if Input.is_action_pressed("Up"):
		move_input = clampi(move_input + 1, -1, 1)
		
	if Input.is_action_pressed("Down"):
		move_input = clampi(move_input - 1, -1, 1)
		
	if Input.is_action_pressed("Left"):
		turn_input = clampi(turn_input + 1, -1, 1)
		
	if Input.is_action_pressed("Right"):
		turn_input = clampi(turn_input - 1, -1, 1)
	
	if Input.is_action_just_pressed("Pause"): GlobalScript.get_pause_menu().toggle_visible(true)
	_send_input()

func _send_input():
	rpc("_receive_input", multiplayer.get_unique_id(), move_input, turn_input)

@rpc("any_peer", "call_local")
func _receive_input(sender_id : int, move : int, turn : int):
	get_parent()._on_received_input(sender_id, move, turn)
