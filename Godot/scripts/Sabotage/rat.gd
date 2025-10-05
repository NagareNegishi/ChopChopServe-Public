extends MeshInstance3D
class_name rat

################################################################################
# TODO:
	# - Clean Code up
	# - Fix timer logic
################################################################################

var target_path
@onready var rat_mischief := []

func set_target(path: NodePath):
	target_path = path

func rat_timer() -> void:
	var timer = Timer.new()
	timer.wait_time = 10.0
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	queue_free()
	print("queue freeded")
