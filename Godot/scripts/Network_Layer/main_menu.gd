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
	Debug.net_log("Try to Create lobby with public IP: " + public_ip)
	network_layer.create_game_with_ip(4, public_ip)
	GlobalScript.player_name = name_input.text
	# Debug.detailed_upnp_test()


## Join Lobby
func _on_join_pressed():
	if name_input.text.length() <= 0 :
		_pop_error(ErrorType.EMPTY_NAME)
		return
	
	# Default is localhost
	var connection_info = ip_input.text.strip_edges()
	if connection_info == "":
		connection_info = "127.0.0.1:7000"
	GlobalScript.player_name = name_input.text

	# Determine if input is a room code or an IP address
	if _is_room_code(connection_info):
		Debug.net_log("Looking up room code: " + connection_info)
		network_layer.lookup_room_code(connection_info)
	else:
		Debug.net_log("Joining with IP: " + connection_info)
		if not network_layer.join_game(connection_info):
			ENetManager.show_notification("Failed to start connection.", 3.0)


## Check if input looks like a room code
## @param input: The input string to check
## @return: True if the input looks like a room code, false otherwise
func _is_room_code(input: String) -> bool:
	# Room codes are 6 characters, alphanumeric, no dots or colons
	if input.length() != 6:
		return false
	if input.contains(".") or input.contains(":"):
		return false
	# Check all characters are alphanumeric
	for c in input:
		if not (c.is_valid_int() or (c >= 'A' and c <= 'Z') or (c >= 'a' and c <= 'z')):
			return false
	return true


## Switch to Lobby
func _switch_to_lobby():
	SceneManager.change_scene(SceneManager.Scene.LOBBY_TEST)


func _exit_game():
	get_tree().quit()


func _pop_error(error : ErrorType):
	match error:
		ErrorType.EMPTY_NAME:
			error_message.text = "Please Enter a Name"
	
	error_message.visible = true
	
	await get_tree().create_timer(4).timeout
	
	error_message.visible = false
