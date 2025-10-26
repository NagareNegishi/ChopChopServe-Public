class_name StartGame extends Area3D

var players : Array[Player] = []
var load_time : float = 1.5
var curr_time : float = 0.0
var increase : bool = false

const num : float = 0.01

@onready var timer : Timer = Timer.new()
@export var label : Label
@export var progress : ProgressBar

func _ready() -> void:
	body_entered.connect(_on_body_enter)
	body_exited.connect(_on_body_exit)
	multiplayer.peer_connected.connect(_list_update)
	
	timer.wait_time = 0.01
	timer.timeout.connect(_on_timeout)
	add_child(timer)
	
	await get_tree().create_timer(0.2).timeout
	
	label.text = "%d/%d" % [peeps_in_area(), ENetManager.get_player_list().size()]
	progress.value = 0
	progress.max_value = load_time


func _on_body_enter(body : Node3D):
	if body is not Player: return
	
	var player : Player = body
	if players.has(player): return
	players.append(player)
	label.text = "%d/%d" % [players.size(), ENetManager.get_player_list().size()]
	if !can_start(): return
	_start_timer.rpc()


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
	
	if curr_time < load_time: return
	
	timer.stop()
	
	for player in GlobalScript.get_all_players():
		player.disable_controls(true, true)
	
	if !ENetManager.is_host(): return
	
	UIManager.play_load()
	
	await get_tree().create_timer(3.5).timeout
	
	ENetManager.start_game()
	SceneManager.change_scene_all_players(SceneManager.Scene.LOBBY)
	

func _list_update(id : int):
	label.text = "%d/%d" % [players.size(), ENetManager.get_player_list().size()]
	increase = peeps_in_area() == ENetManager.get_player_list().size()
	progress.value = 0
	curr_time = 0


func peeps_in_area():
	var amount : int = 0
	for b in self.get_overlapping_bodies():
		amount = amount + 1 if b is Player else 0
	return amount


func can_start():
	var team1_size = ENetManager.get_team1().size()
	var team2_size = ENetManager.get_team2().size()
	var player_size = ENetManager.get_player_list().size()
	
	return players.size() == player_size and \
	team1_size >= 1 and \
	team2_size >= 1 and \
	team1_size + team2_size == player_size

@rpc("any_peer", "call_local")
func _start_timer():
	increase = true
	timer.autostart = true
	timer.start()
