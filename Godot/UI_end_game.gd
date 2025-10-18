extends Control

@onready var button = $ColorRect/Button
@onready var label = $ColorRect/Label

func set_winner(team: int):
	label.text = str(team)

func _on_button_pressed():
	ENetManager.back_to_main_menu
