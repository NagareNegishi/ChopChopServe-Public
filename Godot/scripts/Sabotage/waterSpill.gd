extends Area3D

@export var duration: float = 10.0
@export var slow_down: float = 0.5
		
@onready var reputation_system = ReputationSystem

signal entered_water_spill(body: Node3D)

func start_timer(seconds: float) -> void:
	# Timer For the Water Spill
	var timer = Timer.new()
	timer.wait_time = seconds
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node3D) -> void:
	# Signal to be caught by the player and customers
	# When player dashes they drop their items
	# Customers can slip and fall
	# this causes the team to lose reputation
	emit_signal("entered_water_spill", body)
	print("player in the water")
