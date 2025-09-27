class_name MainMenu
extends Control


var network_layer: ENetNetworkLayer
# Menu UI elements
@onready var menu = $Menu
@onready var create_button = $Menu/ButtonsContainer/HostButton
@onready var host_public_ip_input = $Menu/Note/VBox/IP/PublicIPInput
@onready var join_button = $Menu/ButtonsContainer/JoinButton
@onready var ip_input = $Menu/Note/VBox/IP/PublicIPInput
@onready var exit_button = $Menu/ButtonsContainer/ExitButton
@onready var  error_message = $Menu/Error
@onready var name_input : LineEdit = $Menu/Note/VBox/Name/Name

@export var froggo_building : AnimationPlayer


enum ErrorType{
	EMPTY_NAME
	
}
## Initialization
func _ready():
	network_layer = ENetManager.enet_layer
	create_button.pressed.connect(_on_create_pressed)
	join_button.pressed.connect(_on_join_pressed)
	network_layer.connected.connect(_switch_to_lobby)
	exit_button.pressed.connect(_exit_game)
	
	if !froggo_building : return
	froggo_building.play("ArmatureAction")


## Create Lobby
func _on_create_pressed():
	if name_input.text.length() <= 0 :
		_pop_error(ErrorType.EMPTY_NAME) 
		return
	var public_ip = host_public_ip_input.text.strip_edges()
	network_layer.create_game_with_ip(4, public_ip)
	GlobalScript.player_name = name_input.text


## Join Lobby
func _on_join_pressed():
	if name_input.text.length() <= 0 :
		_pop_error(ErrorType.EMPTY_NAME) 
		return
	
	var connection_info = ip_input.text.strip_edges()
	if connection_info == "":
		connection_info = "127.0.0.1:7000"
	print("Joining lobby at: " + connection_info)
	
	if not network_layer.join_game(connection_info):
		print("Failed to start connection.")
	GlobalScript.player_name = name_input.text


## Switch to Lobby
func _switch_to_lobby():
	SceneManager.change_scene(SceneManager.Scene.LOBBY_TEST)

	# # Change this part to switch stage to bus
	# if network_layer.is_host():
	# 	print("=== HOST CONNECTION INFO ===")
	# 	print("Share with friends: " + network_layer.get_connection_info())
	# 	print("============================")

func _exit_game():
	get_tree().quit()


func _pop_error(error : ErrorType):
	match error:
		ErrorType.EMPTY_NAME:
			error_message.text = "Please Enter a Name"
	
	error_message.visible = true
	
	await get_tree().create_timer(4).timeout
	
	error_message.visible = false
