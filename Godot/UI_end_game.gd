class_name EndScreen extends Control

@export var button : CustomButton
@export var team_1_score : Label
@export var team_2_score : Label
@export var team_name : Label
var is_visible = false


func _on_button_pressed():
	_unpaused.rpc()
	UIManager.play_load()
	
	await get_tree().create_timer(3.5).timeout
	SceneManager.change_scene(SceneManager.Scene.LOBBY)


func _input(event):
	if is_visible and event.is_action_pressed("Interact") && visible:
		_on_button_pressed()

func set_to_visible():
	_ready()
	UIManager.hide_all()
	is_visible = true
	show()

func set_invisible():
	is_visible = false
	hide()

func _lobby():
	_unpaused.rpc()
	UIManager.play_load()
	
	await get_tree().create_timer(3.5).timeout
	SceneManager.change_scene(SceneManager.Scene.HUB)

func _ready() -> void:
	get_tree().paused = true
	button.pressed.connect(_on_button_pressed)
	team_1_score.text = str(int(ReputationSystem.get_reputation(1)))
	team_2_score.text = str(int(ReputationSystem.get_reputation(2)))
	team_name.text = "Team %s Won" % ("Mustard" if get_winner() == 2 else "Tomato")
	if ENetManager.is_host(): return
	button.visible = false

func get_winner() -> int:
	return 1 if ReputationSystem.get_reputation(1) > ReputationSystem.get_reputation(2) else 2

@rpc("any_peer", "call_local")
func _unpaused():
	get_tree().paused = false
