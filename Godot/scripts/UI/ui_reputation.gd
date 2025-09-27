class_name UIReputation
extends Control


@onready var update_timer : Timer = $Timer
@export var teamID : int

var _target_sauce_amount : int

const CHANGE_AMOUNT : float = 0.25

func _ready() -> void:
	ReputationSystem.reputation_changed.connect(_set_reputation)
	$Sauce.value = ReputationSystem.get_reputation(teamID)
	print(ReputationSystem.get_reputation(teamID))


func set_sauce(amount : int) -> void:
	update_timer.stop()
	_target_sauce_amount = amount
	update_timer.start()


func _update_sauce(add : bool) -> void:
	if $Sauce.value == _target_sauce_amount:
		update_timer.stop()
	
	if add:
		$Sauce.value += CHANGE_AMOUNT
	elif !add:
		$Sauce.value -= CHANGE_AMOUNT
	
	
	if $Sauce.value == _target_sauce_amount:
		update_timer.stop()

func _on_timer_timeout() -> void:
	_update_sauce(_target_sauce_amount - $Sauce.value >= 0)

func _set_reputation(team : int, new_reputation : int):
	if team != teamID: return
	set_sauce(new_reputation)
