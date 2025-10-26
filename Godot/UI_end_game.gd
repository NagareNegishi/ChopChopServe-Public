class_name EndScreen extends Control

@export var button : CustomButton
@export var team_1_score : Label
@export var team_2_score : Label
@export var team_name : Label

var is_visible = false


func _on_button_pressed():
	SceneManager.change_scene(SceneManager.Scene.LOBBY)
	set_invisible()

func _input(event):
	if is_visible and event.is_action_pressed("Interact") && visible:
		_on_button_pressed()

func set_to_visible():
	is_visible = true
	show()

func set_invisible():
	is_visible = false
	hide()


func _ready() -> void:
	team_1_score.text = str(ReputationSystem.get_reputation(1))
	team_2_score.text = str(ReputationSystem.get_reputation(2))
	team_name.text = "Team %s Won" % ("Mustard" if get_winner() == 2 else "Tomato")

func get_winner() -> int:
	return 1 if ReputationSystem.get_reputation(1) > ReputationSystem.get_reputation(2) else 2
