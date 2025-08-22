class_name PlayerCarController
extends MultiplayerSynchronizer

@onready var move_input : int
@onready var turn_input : int

@onready var input_timer : Timer = Timer.new()

func _ready() -> void:
	add_child(input_timer)
	input_timer.wait_time = 0.1
	input_timer.timeout.connect(_send_input)
	input_timer.autostart = true
	input_timer.start()

	
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

func _send_input():
	rpc("_receive_input", multiplayer.get_unique_id(), move_input, turn_input)

@rpc("any_peer", "call_local")
func _receive_input(sender_id : int, move : int, turn : int):
	get_parent()._on_received_input(sender_id, move, turn)
