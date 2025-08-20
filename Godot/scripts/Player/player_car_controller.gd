class_name PlayerCarController
extends MultiplayerSynchronizer

@onready var move_input : int
@onready var turn_input : int

func _ready() -> void:
	pass
	
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
