class_name UIReputation
extends Control


@onready var update_timer : Timer = $Timer


var target_sauce_amount : int

func _ready() -> void:
	pass
	

func set_sauce(amount : int, anim : bool) -> void:
	update_timer.stop()
	if anim:
		$Sauce.value = amount
	else:
		target_sauce_amount = amount
		update_timer.start()


func _update_sauce(add : bool) -> void:
	if $Sauce.value == target_sauce_amount:
		update_timer.stop()
	
	if add:
		$Sauce.value += 1
	elif !add:
		$Sauce.value -= 1
	
	if $Sauce.value == target_sauce_amount:
		update_timer.stop()

func _on_timer_timeout() -> void:
	_update_sauce(target_sauce_amount - $Sauce.value >= 0)
