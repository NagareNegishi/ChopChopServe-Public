extends Area3D

@export var duration: float = 10.0
@export var slow_down: float = 0.5
		
@onready var reputation_system = ReputationSystem



func start_timer(seconds: float) -> void:
	print("timer on")
	var timer = Timer.new()
	timer.wait_time = seconds
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	queue_free()

# When the Player enters the water.
func _on_area_3d_body_entered(_body:Node3D) -> void:
	print("Player entereed water")
	#if body is Player:
		#reputation_system.add_reputation(3)
	#if body.is_in_group("player"):
	
	#	res://Milestone2Submission.tscn
	#	# write this in the plyer script
	#	body.apply_slow(slow_down, self)
	#elif body.is_in_group("customer"):
	#	if randf() < 0.1:
	#		$ReputationSystem.add_reputation(-3)

# when the Player exits the water
func _on_area_3d_body_exited(_body:Node3D) -> void:
	print("Player exited water")
	#if body.is_in_group("player"):
		# Handle player exiting the spill area
	#	print("Player exited water spill area")


		
