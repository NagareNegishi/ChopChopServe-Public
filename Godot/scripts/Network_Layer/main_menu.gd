class_name MainMenu
extends Control


var network_layer: ENetNetworkLayer
# Menu UI elements
@onready var menu = $Menu
@onready var create_button = $Menu/HostContainer/CreateButton
@onready var host_public_ip_input = $Menu/HostContainer/HostPublicIPInput
@onready var join_button = $Menu/ClientContainer/JoinButton
@onready var ip_input = $Menu/ClientContainer/ClientIPInput


## Initialization
func _ready():
	network_layer = ENetManager.enet_layer
	create_button.pressed.connect(_on_create_pressed)
	join_button.pressed.connect(_on_join_pressed)
	network_layer.connected.connect(_switch_to_lobby)


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
	SceneManager.change_scene(SceneManager.Scene.LOBBY_TEST)

	# # Change this part to switch stage to bus
	# if network_layer.is_host():
	# 	print("=== HOST CONNECTION INFO ===")
	# 	print("Share with friends: " + network_layer.get_connection_info())
	# 	print("============================")
