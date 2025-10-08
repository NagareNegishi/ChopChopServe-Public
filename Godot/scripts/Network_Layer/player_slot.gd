extends Control
class_name PlayerSlot


@onready var kick_button: Button = $KickButton
var player_data: Dictionary


func _ready():
	custom_minimum_size = Vector2(150, 150) # reserve space in lobby
	kick_button.pressed.connect(_on_kick_pressed)
	kick_button.visible = false
	visible = false


func set_player(data: Dictionary) -> void:
	player_data = data
	#name_label.text = data.get("name", "Waiting...")


func get_player() -> Dictionary:
	return player_data


func show_kick_button() -> void:
	kick_button.visible = true


func _on_kick_pressed() -> void:
	var player_id = player_data.get("ID", -1)
	if player_id != -1:
		ENetManager.player_leaves_intentionally(player_id)
