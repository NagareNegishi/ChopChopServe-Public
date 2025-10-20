class_name StartGame extends Area3D

var players : Array[Player] = []
var load_time : float = 2.0
var curr_time : float = 0.0
var increase : bool = false

const num : float = 0.01

@onready var timer : Timer = Timer.new()
@export var label : Label
@export var progress : ProgressBar

func _ready() -> void:
	body_entered.connect(_on_body_enter)
	body_exited.connect(_on_body_exit)
	ENetManager.player_list_updated.connect(list_update)
	
	timer.wait_time = 0.01
	timer.timeout.connect(_on_timeout)
	add_child(timer)
	
	label.text = "%d/%d" % [players.size(), ENetManager.get_player_list().size()]
	progress.value = 0
	progress.max_value = load_time


func _on_body_enter(body : Node3D):
	if body is not Player: return
	
	var player : Player = body
	if players.has(player): return
	players.append(player)
	label.text = "%d/%d" % [players.size(), ENetManager.get_player_list().size()]
	if !players.size() == ENetManager.player_list.size(): return
	increase = true
	timer.autostart = true
	timer.start()


func _on_body_exit(body : Node3D):
	if body is not Player: return
	
	var player : Player = body
	if !players.has(player): return
	players.erase(player)
	
	increase = players.size() == ENetManager.player_list.size()
	label.text = "%d/%d" % [players.size(), ENetManager.get_player_list().size()]

	

func _on_timeout():
	curr_time += num if increase else -num/2
	progress.value = curr_time
	
	if curr_time <= 0:
		curr_time = 0
		timer.stop()
		return
	
	if !ENetManager.is_host() ||  ENetManager.is_host() && curr_time < load_time: return
	
	timer.stop()
	
	for id in ENetManager.get_player_list():
		GlobalScript.get_local_player_by_id(id).disable_controls(true, true)
		
	UIManager.play_load()
	
	await get_tree().create_timer(3.5).timeout
	
	SceneManager.change_scene_all_players(SceneManager.Scene.LOBBY)
	

func list_update():
	label.text = "%d/%d" % [players.size(), ENetManager.get_player_list().size()]
