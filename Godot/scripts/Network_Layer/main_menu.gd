class_name MainMenu
extends Control


var network_layer: ENetNetworkLayer
# Menu UI elements
@onready var menu = $Menu
@onready var create_button = $Menu/HostContainer/CreateButton
@onready var host_public_ip_input = $Menu/HostContainer/HostPublicIPInput
@onready var join_button = $Menu/ClientContainer/JoinButton
@onready var ip_input = $Menu/ClientContainer/ClientIPInput
# Lobby UI elements
@onready var lobby_screen = $LobbyScreen
@onready var player1_label = $LobbyScreen/VBoxContainer/HBoxContainer/Player1
@onready var player2_label = $LobbyScreen/VBoxContainer/HBoxContainer/Player2
@onready var player3_label = $LobbyScreen/VBoxContainer/HBoxContainer/Player3
@onready var player4_label = $LobbyScreen/VBoxContainer/HBoxContainer/Player4
@onready var leave_button = $LobbyScreen/VBoxContainer/LeaveButton


## Initialization
func _ready():
	network_layer = ENetManager.enet_layer
	create_button.pressed.connect(_on_create_pressed)
	join_button.pressed.connect(_on_join_pressed)
	leave_button.pressed.connect(_on_leave_pressed)
	network_layer.connected.connect(_switch_to_lobby)
	ENetManager.player_list_updated.connect(_update_player_list)
	ENetManager.disconnected_from_server.connect(_switch_to_menu)


## Create Lobby
func _on_create_pressed():
	var public_ip = host_public_ip_input.text.strip_edges()
	network_layer.create_game_with_ip(4, public_ip)


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
	change_scene("res://scenes/Network_Layer/lobby_network.tscn")

	# # Change this part to switch stage to bus
	# menu.hide()
	# lobby_screen.show()
	
	# if network_layer.is_host():
	# 	print("=== HOST CONNECTION INFO ===")
	# 	print("Share with friends: " + network_layer.get_connection_info())
	# 	print("============================")


## Switch to Menu
func _switch_to_menu():
	lobby_screen.hide()
	menu.show()


## Leave Lobby
func _on_leave_pressed():
	var my_id = network_layer.get_my_id()
	if network_layer.is_host():
		# Host can directly call the function
		ENetManager.player_leaves_intentionally(my_id)
	else:
		# Client notifies host they're leaving
		ENetManager.enet_layer.send_to(1, {
			"type": "player_leaving_intentionally",
			"player_id": my_id
		})
		await get_tree().create_timer(0.1).timeout # Small delay to ensure message is sent
		network_layer.leave_game()
	_switch_to_menu()



## Update Player List UI probably replace it with image??
func _update_player_list(player_list: Array[int] = []):
	var my_id = network_layer.get_my_id()
	if player_list.is_empty():
		player_list = ENetManager.get_player_list()
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


## Helper Functions to Change Scenes
func change_scene(scene_path: String):
	## "res://scenes/Network_Layer/lobby_network.tscn"
	get_tree().call_deferred("change_scene_to_file", scene_path)
