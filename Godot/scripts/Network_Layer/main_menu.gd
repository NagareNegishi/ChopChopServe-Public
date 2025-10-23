class_name MainMenu
extends Control


var network_layer: ENetNetworkLayer
var room_list_popup: RoomListPopup
# Menu UI elements
@onready var menu = $Menu
@onready var create_button = $Menu/ButtonsContainer/HostButton
@onready var host_public_ip_input = $Menu/Note/VBox/IP/PublicIPInput
@onready var join_button = $Menu/ButtonsContainer/JoinButton
@onready var ip_input = $Menu/Note/VBox/IP/PublicIPInput
@onready var exit_button = $Menu/ButtonsContainer/ExitButton
@onready var  test_button = $Menu/ButtonsContainer/TestButton
@onready var tutorial_button = $Menu/ButtonsContainer/TutorialButton
@onready var  search_button = $Menu/ButtonsContainer/SearchButton
@onready var  error_message = $Menu/Error

@onready var name_input : LineEdit = $Menu/Note/VBox/Name/Name

@export var froggo_building : AnimationPlayer


enum ErrorType{
	EMPTY_NAME
	
}
## Initialization
func _ready():
	network_layer = ENetManager.enet_layer
	_setup_room_list_popup()
	create_button.pressed.connect(_on_create_pressed)
	join_button.pressed.connect(_on_join_pressed)
	network_layer.connected.connect(_switch_to_lobby)
	exit_button.pressed.connect(_exit_game)
	test_button.pressed.connect(_diagnose_network)
	tutorial_button.pressed.connect(_on_tutorial_pressed)
	search_button.pressed.connect(_on_search_pressed)
	network_layer.tutorial_started.connect(_on_tutorial_started)
	network_layer.rooms_list_received.connect(_on_rooms_list_received)
	network_layer.http_request_failed.connect(_on_http_request_failed)
	if !froggo_building : return
	froggo_building.play("ArmatureAction", -1, 0.6)
	SoundManager.play_bgm(SoundManager.BGM.MENU, 2.0)
	SoundManager.play_sfx_player(SoundManager.SFX_PLAYER.JUMP)


## Setup Room List Popup
func _setup_room_list_popup():
	var room_list_popup_scene = preload("res://scenes/Network_Layer/room_list_popup.tscn")
	room_list_popup = room_list_popup_scene.instantiate() as RoomListPopup
	add_child(room_list_popup)
	room_list_popup.room_selected.connect(_on_room_selected)


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
	SceneManager.change_scene(SceneManager.Scene.HUB)
	#SceneManager.change_scene(SceneManager.Scene.LOBBY_TEST)


## Exit Game
func _exit_game():
	get_tree().quit()


## Pop up error message
func _pop_error(error : ErrorType):
	match error:
		ErrorType.EMPTY_NAME:
			error_message.text = "Please Enter a Name"
	error_message.visible = true
	await get_tree().create_timer(4).timeout
	error_message.visible = false


## Diagnose Network connection
func _diagnose_network():
	test_button.disabled = true
	test_button.text = "Testing..."
	var diagnostics = NetworkDiagnostics.new()
	add_child(diagnostics)
	diagnostics.setup(network_layer)
	# Run diagnostics
	var user_ip = host_public_ip_input.text.strip_edges()
	var results = await diagnostics.run_diagnostics(user_ip)
	# Format and show results
	var report = diagnostics.format_short_results(results)
	ENetManager.show_notification(report, 5.0)
	Debug.net_log(diagnostics.format_results(results))
	diagnostics.queue_free()
	test_button.disabled = false
	test_button.text = "Connection Help"


## Tutorial Button Pressed
func _on_tutorial_pressed():
	network_layer.create_tutorial()
	GlobalScript.player_name = name_input.text


## Tutorial Started Signal Handler
func _on_tutorial_started():
	Debug.net_log("Tutorial started, Current player list: " + str(ENetManager.get_player_list()))
	SceneManager.change_scene(SceneManager.Scene.TUTORIAL)


## Ask the network layer to search for active rooms
func _on_search_pressed():
	search_button.disabled = true
	search_button.text = "Searching host..."
	network_layer.get_active_rooms()


## Handle HTTP request failure
func _on_http_request_failed():
	search_button.disabled = false
	search_button.text = "SEARCH HOST"


## Show received rooms in popup
## @param rooms: Array of room info dictionaries
func _on_rooms_list_received(rooms: Array):
	search_button.disabled = false
	search_button.text = "SEARCH HOST"
	if rooms.is_empty():
		ENetManager.show_notification("No active rooms found.", 2.0)
	else:
		room_list_popup.show_rooms(rooms)


## Fill in IP input when a room is selected
## @param room_code: The selected room code
func _on_room_selected(room_code: String):
	ip_input.text = room_code










## Unknown functions, are using them somewhere else?----------------------------------------
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_on_join_pressed()

func tutorial():
	get_tree().change_scene_to_file("res://LevelDesign/Tutorial.tscn")
	test_button.text = "CONNECTION HELP"
