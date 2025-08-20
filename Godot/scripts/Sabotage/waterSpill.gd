extends Area3D

@export var slow_factor: float = 0.5
@export var duration: float = 10.0
@onready var timer = $Timer

func start_timer(seconds: float) -> void:
	timer.start(seconds)

func _on_timer_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("players"):
		body.apply_slow(slow_factor, self)   # Player.gd handles it
	elif body.is_in_group("customers"):
		if randf() < 0.1:
			$ReputationSystem.add_reputation(-3)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("players"):
		body.remove_slow(self)
