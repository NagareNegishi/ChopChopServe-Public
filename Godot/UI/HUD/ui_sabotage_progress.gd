class_name SabotageProgress extends Control

const sabotage_progress : PackedScene = preload("res://UI/HUD/UI_SabotageProgress.tscn")

@onready var timer : Timer = $Timer
@onready var progress_bar : TextureProgressBar = $ProgressBar

var time_max : float = 0
var time_curr : float = 0
var texture_sabo : Texture
const map = {
	"Water Spill" : 1,
	"Fire Spread" : 2,
	"Food Critic" : 3,
	"Switch Controls" : 4,
	"Rat Swarm" : 5,
	"Power Outage" : 6
}
static func create(time : int, sabo : String) -> SabotageProgress:
	var result : SabotageProgress = sabotage_progress.instantiate()
	result.time_max = float(time)
	result.texture_sabo = ResourceLoader.load("res://assets/textures/Sabotage/" + str(map[sabo]) +".png")
	return result


func _ready() -> void:
	timer.timeout.connect(timeout)
	progress_bar.texture_progress = texture_sabo
	progress_bar.texture_under = texture_sabo

func timeout():
	if time_max == 0: return
	
	time_curr += timer.wait_time
	progress_bar.value = time_curr / time_max
	
	if time_curr < time_max: return
	timer.stop()
	queue_free()
