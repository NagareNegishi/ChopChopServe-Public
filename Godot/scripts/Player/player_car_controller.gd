class_name PlayerCarController
extends MultiplayerSynchronizer

@onready var move_input : int
@onready var turn_input : int

var last_move : int = 0
var last_turn : int = 0
var time : int = 0

func _process(delta: float) -> void:
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
	
	if last_move != move_input || last_turn != turn_input:
		last_move = move_input
		last_turn = turn_input
		_send_input(true)
	_send_input(false)
	
	
func _send_input(new : bool):
	time = time if !new else Time.get_ticks_msec()
	rpc("_receive_input", multiplayer.get_unique_id(), move_input, turn_input, time)


@rpc("any_peer", "call_local", "unreliable")
func _receive_input(sender_id : int, move : int, turn : int, ttime : int):
	get_parent()._on_received_input(sender_id, move, turn, ttime)
