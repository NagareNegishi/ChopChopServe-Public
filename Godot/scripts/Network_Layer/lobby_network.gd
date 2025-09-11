# lobby_network.gd
extends Control
class_name LobbyNetwork

@onready var role_label: Label = $RoleLabel
@onready var team_label: Label = $TeamLabel
@onready var buttons_container: Container = $ControlContainer
@onready var shuffle_button: Button = $ControlContainer/ShuffleButton
@onready var start_button: Button = $ControlContainer/StartButton
@onready var leave_button: Button = $ControlContainer/LeaveButton

@onready var player_list_root: HBoxContainer = $PlayerList
@onready var slot1: PlayerSlot = $PlayerList/PanelContainer
@onready var slot2: PlayerSlot = $PlayerList/PanelContainer2
@onready var slot3: PlayerSlot = $PlayerList/PanelContainer3
@onready var slot4: PlayerSlot = $PlayerList/PanelContainer4

var network_layer: ENetNetworkLayer
var slot_scene: PackedScene
var current_players: Array[int] = []
var slots: Array[PlayerSlot]
var is_host: bool = false
var my_id: int = -1
var my_team: int = -1


## Setup
func _ready():
	network_layer = ENetManager.enet_layer
	my_id = network_layer.get_my_id()
	slots = [slot1, slot2, slot3, slot4]

	ENetManager.player_list_updated.connect(_on_player_list_updated)
	ENetManager.disconnected_from_server.connect(_back_to_main_menu)
	ENetManager.back_to_main_menu.connect(_back_to_main_menu)
	ENetManager.team_assigned.connect(_on_team_assigned)
	ENetManager.game_started.connect(_start_game)
	leave_button.pressed.connect(_on_leave_pressed)
	shuffle_button.pressed.connect(ENetManager.shuffle_players)
	start_button.pressed.connect(ENetManager.start_game)

	if network_layer.is_host():
		is_host = true
		current_players = ENetManager.get_player_list()
		_update_player_list()

	_set_role_label()
	_set_team_label(my_team)
	_set_buttons()


## Set Role Label
func _set_role_label() -> void:
	if is_host:
		role_label.text = "You are: Host (Player %d)" % my_id
	else:
		role_label.text = "You are: Client (Player %d)" % my_id


## Set Team Label
func _set_team_label(team_number: int) -> void:
	if team_number == -1:
		team_label.text = "Team: Unassigned"
	else:
		team_label.text = "Team: %d" % team_number


## Set Buttons
func _set_buttons() -> void:
	shuffle_button.visible = is_host
	start_button.visible = is_host
	shuffle_button.disabled = true
	start_button.disabled = true


## Update Player List
func _update_player_list():
	#print("Updating display... on :", network_layer.get_my_id())
	for i in range(4):
		var slot = slots[i]
		if i < current_players.size():
			var player_id = current_players[i]
			var player_name = "Player %d" % i
			if player_id == my_id:
				player_name += " (You)"
			slot.set_player({
				"name": player_name,
				"ID": player_id
			})
			slot.visible = true
			if is_host and player_id != my_id:
				slot.show_kick_button()
		else:
			slot.set_player({"name": "Waiting..."})
			slot.visible = false


## Signal Handlers from ENetManager
func _on_player_list_updated(players: Array[int] = []):
	current_players = players.duplicate()
	_update_player_list()
	print("Lobby updated - Players: %s" % str(players))
	if is_host:
		start_button.disabled = true
		if current_players.size() % 2 == 0:
			shuffle_button.disabled = false
		else:
			shuffle_button.disabled = true


## Leave Button Pressed
func _on_leave_pressed():
	if is_host:
		# Host can directly call the function
		ENetManager.player_leaves_intentionally(my_id)
	else:
		# Client notifies host they're leaving
		network_layer.send_to(1, {
			"type": "player_leaving_intentionally",
			"player_id": my_id
		})
		await get_tree().create_timer(0.1).timeout # Small delay to ensure message is sent
		# network_layer.leave_game()
	# back_to_main_menu()


## Signal Handlers from ENetManager, assign teams and display
func _on_team_assigned(team1: Array[int], team2: Array[int]) -> void:
	if my_id in team1:
		my_team = 1
	elif my_id in team2:
		my_team = 2
	_set_team_label(my_team)
	if is_host:
		start_button.disabled = not ENetManager.can_start_game()


## Start Game
func _start_game() -> void:
	buttons_container.hide()
	player_list_root.hide()
##----------------------------------------------------------------------------------
## need more logic here.
## can Lobby scene take over? or should we create a new scene for the game?
	_change_scene("res://Milestone3Submission.tscn")
##----------------------------------------------------------------------------------


## Back to Main Menu
func _back_to_main_menu() -> void:
	_change_scene("res://scenes/Network_Layer/main_menu.tscn")


## Helper Functions to Change Scenes
func _change_scene(scene_path: String):
	get_tree().call_deferred("change_scene_to_file", scene_path)
