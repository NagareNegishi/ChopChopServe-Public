class_name SabotageProgress extends Control

const sabotage_progress : PackedScene = preload("res://UI/HUD/UI_SabotageProgress.tscn")

@onready var timer : Timer = $Timer
@onready var progress_bar : TextureProgressBar = $ProgressBar

var time_max : float = 0
var time_curr : float = 0

static func create(time : int) -> SabotageProgress:
	var result : SabotageProgress = sabotage_progress.instantiate()
	result.time_max = float(time)
	return result


func _ready() -> void:
	timer.timeout.connect(timeout)


func timeout():
	if time_max == 0: return
	
	time_curr += timer.wait_time
	progress_bar.value = time_curr / time_max
	
	if time_curr < time_max: return
	timer.stop()
	queue_free()
