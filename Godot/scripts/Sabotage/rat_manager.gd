extends Node

var secs = 8.0
var teamID

func testing_rat_timer() -> void:
	print("jess: RAT MANAGER TIMER")
	var timer = Timer.new()
	timer.wait_time = secs
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	SabotageSystem.sabotage_start.emit(teamID, "Rat Swarm", secs)

func set_team_id(team_id: int) -> void:
	teamID = team_id

func _on_timer_timeout() -> void:
	# This should make the rats turn around when the timer is up 
	# Instead of just disapearing when itsover
	RatAttack.change_state()
	print("jess: RAT MANAGER TIMER has ended")
	#queue_free()
	SabotageSystem.sabotage_ending.emit(teamID, "Rat Swarm")