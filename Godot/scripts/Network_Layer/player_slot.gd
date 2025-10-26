extends Control
class_name PlayerSlot

enum Team {
	UNASSIGNED,
	TEAM1,
	TEAM2
}

@onready var kick_button: Button = $KickButton
@onready var team1_button: Button = $JoinTeam1Button
@onready var team2_button: Button = $JoinTeam2Button
@onready var name_label: Label = $NameLabel
@onready var is_local: TextureRect = $BG_Outline # Local player indicator (temporary)
var player_data: Dictionary
var current_team: Team = Team.UNASSIGNED
var slot_index: int = -1


## Setup the player slot
func _ready():
	custom_minimum_size = Vector2(150, 150) # reserve space in lobby
	kick_button.pressed.connect(_on_kick_pressed)
	team1_button.pressed.connect(_on_join_team1_pressed)
	team2_button.pressed.connect(_on_join_team2_pressed)
	_setup_buttons()
	visible = false


## Setup button visibility and layering
func _setup_buttons():
	kick_button.visible = false
	kick_button.z_index = 10
	kick_button.z_as_relative = true
	team1_button.visible = false
	team1_button.z_index = 10
	team1_button.z_as_relative = true
	team2_button.visible = false
	team2_button.z_index = 10
	team2_button.z_as_relative = true
	# Ignore mouse on all children except buttons (visual elements blocking button)
	for child in get_children():
		if child is Control and not child is Button:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE


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
## @param local: True to highlight as local player, false for normal
func set_as_local_player(local: bool):
	if local:
		is_local.modulate = Color(1.0, 0.8, 0.0)  # Gold/yellow tint
	else:
		is_local.modulate = Color(1.0, 1.0, 1.0)  # White (default)


## Set the outline color for this slot
## @param color: The Color to set the outline to
func set_outline_color(color: Color):
	is_local.modulate = color


## Set visibility of team join buttons based on current team sizes
func _check_team_buttons():
	if ENetManager.get_team1().size() < 2:
		team1_button.show()
	else:
		team1_button.hide()
	if ENetManager.get_team2().size() < 2:
		team2_button.show()
	else:
		team2_button.hide()


## Hide both team join buttons
func _hide_team_buttons():
	team1_button.hide()
	team2_button.hide()


## Join Team 1 button pressed handler
func _on_join_team1_pressed():
	var player_id = player_data.get("ID", -1)
	if player_id == -1:
		return
	ENetManager.enet_layer.send_to(1, {  # 1 is always the host
		"type": "request_team_join",
		"player_id": player_id,
		"team": 1
	})


## Join Team 2 button pressed handler
func _on_join_team2_pressed():
	var player_id = player_data.get("ID", -1)
	if player_id == -1:
		return
	ENetManager.enet_layer.send_to(1, {
		"type": "request_team_join",
		"player_id": player_id,
		"team": 2
	})


## Set the current team and update UI
## @param team: The team number (1 or 2) to set, or unassigned
func set_team(team: int) -> void:
	var player_id = player_data.get("ID", -1)
	var local = player_id == ENetManager.get_my_id()
	match team:
		1:
			current_team = Team.TEAM1
			if local:
				#TODO: low priority, could add leave team button and show it here
				_hide_team_buttons()

		2:
			current_team = Team.TEAM2
			if local:
				_hide_team_buttons()
		_:
			current_team = Team.UNASSIGNED
			if local:
				_check_team_buttons()


## Get the current team as an integer
## @return: 1 for Team 1, 2 for Team 2, -1 for unassigned
func get_team() -> int:
	match current_team:
		Team.TEAM1:
			return 1
		Team.TEAM2:
			return 2
		_:
			return -1
