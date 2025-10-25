class_name EndScreen extends Control

@onready var button = $Button
@onready var label = $Label

var is_visible = false

func set_winner(team: int):
	label.text = str(team)

func _on_button_pressed():
	SceneManager.change_scene(SceneManager.Scene.LOBBY)
	set_invisible()

func _input(event):
	if is_visible and event.is_action_pressed("Interact"):
		_on_button_pressed()

func set_to_visible():
	is_visible = true
	show()

func set_invisible():
	is_visible = false
	hide()
