extends Area3D

@export var duration: float = 10.0
@export var slow_down: float = 0.5
		
@onready var reputation_system = ReputationSystem

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
	if body is Player:
		print("player in the water")
		# Need to make it so the player trips
		#reputation_system.add_reputation(3)
	#if body is Costomer:
		#print("Costomer detected etc")
		# random chance of the customer tripping logic
		# needed to be added here !!
