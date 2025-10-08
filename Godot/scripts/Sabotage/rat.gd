extends MeshInstance3D
class_name rat

################################################################################
# TODO:
	# - Clean Code up
	# - Fix timer logic
	# - Add a signal to allow the rats to go home when the time ends, rather then just disapare.
################################################################################

var target_path
@onready var rat_mischief := []
var secs = 10.0

func set_target(path: NodePath):
	target_path = path

func rat_timer() -> void:
	var timer = Timer.new()
	timer.wait_time = secs
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	SabotageSystem.sabotage_start.emit("Rat Swarm", secs)

func _on_timer_timeout() -> void:
	# This should make the rats turn around when the timer is up 
	# Instead of just disapearing when itsover
	RatAttack.change_state()
	print("jess: the timer has ended and the rat state should be changing")
	#queue_free()
	SabotageSystem.sabotage_ending.emit("Rat Swarm")
