extends Control
class_name PlayerSlot


@onready var kick_button: Button = $KickButton
@onready var name_label: Label = $NameLabel
@onready var is_local: TextureRect = $BG_Outline # Local player indicator (temporary)
var player_data: Dictionary


## Setup the player slot
func _ready():
	custom_minimum_size = Vector2(150, 150) # reserve space in lobby
	kick_button.pressed.connect(_on_kick_pressed)
	kick_button.visible = false
	kick_button.z_index = 10
	kick_button.z_as_relative = true
	# Ignore mouse on all children except buttons (visual elements blocking button)
	for child in get_children():
		if child is Control and not child is Button:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


## Set the player data and update UI
# @param data: Dictionary containing player information
func set_player(data: Dictionary) -> void:
	player_data = data
	name_label.text = data.get("name", "Waiting...")


## Get the player data
func get_player() -> Dictionary:
	return player_data


## Show the kick button (only for host)
func show_kick_button() -> void:
	kick_button.visible = true


## Kick button pressed handler (only for host)
func _on_kick_pressed() -> void:
	Debug.net_log("Kick button pressed for player: " + player_data.get("name", "Unknown"))
	var player_id = player_data.get("ID", -1)
	if player_id != -1:
		ENetManager.player_leaves_intentionally(player_id)


## Highlight this slot as the local player
func set_as_local_player():
	is_local.modulate = Color(1.0, 0.8, 0.0)  # Gold/yellow tint


## Remove local player highlight
func remove_local_highlight():
	is_local.modulate = Color(1.0, 1.0, 1.0)  # White (default)


## Set the outline color for this slot
func set_outline_color(color: Color):
	is_local.modulate = color
