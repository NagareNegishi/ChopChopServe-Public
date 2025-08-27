class_name Lobby
extends Control

var player_list: Array[int] = []
var team1: Array[int] = []
var team2: Array[int] = []

@onready var network_layer = $NetworkLayer
# Menu UI elements
@onready var menu = $Menu
@onready var create_button = $Menu/VBoxContainer/CreateButton
@onready var host_public_ip_input = $Menu/VBoxContainer/HostPublicIPInput
@onready var join_button = $Menu/VBoxContainer/JoinButton
@onready var ip_input = $Menu/VBoxContainer/ClientIPInput
# Lobby UI elements
@onready var lobby_screen = $LobbyScreen
@onready var player1_label = $LobbyScreen/VBoxContainer/HBoxContainer/Player1
@onready var player2_label = $LobbyScreen/VBoxContainer/HBoxContainer/Player2
@onready var player3_label = $LobbyScreen/VBoxContainer/HBoxContainer/Player3
@onready var player4_label = $LobbyScreen/VBoxContainer/HBoxContainer/Player4
@onready var leave_button = $LobbyScreen/VBoxContainer/LeaveButton


## Initialization
func _ready():
	create_button.pressed.connect(_on_create_pressed)
	join_button.pressed.connect(_on_join_pressed)
	leave_button.pressed.connect(_on_leave_pressed)
	network_layer.player_joined.connect(_on_player_joined)
	network_layer.player_left.connect(_on_player_left)
	network_layer.connected.connect(_switch_to_lobby)
	network_layer.data_received.connect(_on_data_received)


## Create Lobby
func _on_create_pressed():
	var public_ip = host_public_ip_input.text.strip_edges()
	if network_layer.create_game_with_ip(4, public_ip):
		player_list = [1]
		_switch_to_lobby()
	else:
		print("Failed to create lobby")


## Join Lobby
func _on_join_pressed():
	var connection_info = ip_input.text.strip_edges()
	if connection_info == "":
		connection_info = "127.0.0.1:7000"
	print("Joining lobby at: " + connection_info)
	if not network_layer.join_game(connection_info):
		print("Failed to start connection.")


## Switch to Lobby
func _switch_to_lobby():
	menu.hide()
	lobby_screen.show()
	_update_player_list()
	
	if network_layer.is_host():
		print("=== HOST CONNECTION INFO ===")
		print("Share with friends: " + network_layer.get_connection_info())
		print("============================")


## Switch to Menu
func _switch_to_menu():
	lobby_screen.hide()
	menu.show()
	player_list.clear()


## Leave Lobby
func _on_leave_pressed():
	network_layer.leave_game()
	_switch_to_menu()


## Update Player List when a player joins, and host shares it
## @param player_id: The ID of the player who joined
func _on_player_joined(player_id: int):
	print("Player joined: " + str(player_id))
	if player_id not in player_list:
		player_list.append(player_id)
	if network_layer.is_host():
		network_layer.broadcast({
			"type": "player_list_update",
			"players": player_list
		})


## Update Player List when a player leaves, and host shares it
## @param player_id: The ID of the player who left
func _on_player_left(player_id: int):
	print("Player left: " + str(player_id))
	if player_id in player_list:
		player_list.erase(player_id)
	if network_layer.is_host():
		network_layer.broadcast({
			"type": "player_list_update",
			"players": player_list
		})


## Data Received
## @param from_id: The ID of the player who sent the data
## @param data: The data received from the player
func _on_data_received(from_id: int, data: Dictionary):
	if data.type == "player_list_update":
		player_list = data.players
		_update_player_list()


## Update Player List UI probably replace it with image??
func _update_player_list():
	var my_id = network_layer.get_my_id()
	var labels = [player1_label, player2_label, player3_label, player4_label]
	
	# Update each label using our ordered list
	for i in range(4):
		if i < player_list.size():
			var player_id = player_list[i]
			var text = "Player " + str(player_id)
			if player_id == 1:
				text += " (Host)"
			if player_id == my_id:
				text += " (You)"
			labels[i].text = text
		else:
			labels[i].text = "Empty"