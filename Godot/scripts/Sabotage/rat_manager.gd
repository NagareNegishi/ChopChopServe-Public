extends Node

var secs = 8.0
var teamID

# Timer for a mischeif of rats
func rat_timer() -> void:
	print("jess: RAT MANAGER TIMER")
	var timer = Timer.new()
	timer.wait_time = secs
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	SabotageSystem.sabotage_start.emit(teamID, "Rat Swarm", secs)

# Make the Rats turn around and go home once
# The timer is finished
func _on_timer_timeout() -> void:
	RatAttack.change_state()
	print("jess: RAT MANAGER TIMER has ended")
	#queue_free()
	SabotageSystem.assigned_benches.clear()
	SabotageSystem.sabotage_ending.emit(teamID, "Rat Swarm")

# # Get the teamID to use
func set_team_id(team_id: int) -> void:
	teamID = team_id