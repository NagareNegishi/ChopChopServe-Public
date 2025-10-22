extends Area3D

@export var level : SceneManager.Scene
@export var car : PlayerCar
@export var _progress : TextureProgressBar
@export var timer : Timer
@export var level_name : String
@export var level_widget : LevelName

var curr_time : float
var max_time :float = 2.5
var increase : bool = true

func _ready() -> void:
	_progress.max_value = max_time
	level_widget._set_text(level_name)
	area_entered.connect(_area_entered)
	timer.timeout.connect(_timeout)
	timer.stop()


func _area_entered(area : Area3D):
	timer.autostart = true
	timer.start()
	increase = true

func _area_exited(area : Area3D):
	increase = false


func _timeout():
	curr_time += timer.wait_time if increase else -timer.wait_time
	_progress.value = curr_time
	if curr_time <= 0: 
		timer.stop()
		_progress.value = 0
		curr_time = 0
		return
	
	if curr_time < max_time: return
	timer.stop()
	car.disable_input(true)
	
	if !ENetManager.is_host(): return
	
	UIManager.play_load()
	
	await get_tree().create_timer(3.5).timeout
	
	SceneManager.change_scene_all_players(level)
