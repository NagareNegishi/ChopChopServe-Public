extends Area3D

@export var duration: float = 10.0
@export var slow_down: float = 0.5
@onready var timer = $Timer

func start_timer(seconds: float) -> void:
	timer.start(seconds)

func _on_timer_timeout() -> void:
	queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):  # safer for multiplayer
		print("Player entered water")
		var rep_system = get_tree().root.get_node("Main/ReputationSystem")
		rep_system.add_reputation(-3)
		# body.apply_slow(slow_down, self)  # if implemented

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("Player exited water")