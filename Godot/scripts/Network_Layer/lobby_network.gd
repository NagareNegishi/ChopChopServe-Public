# lobby_network.gd
extends Control
class_name LobbyNetwork

@onready var role_label: Label = $RoleLabel
@onready var team_label: Label = $TeamLabel
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


func _ready():
	network_layer = ENetManager.enet_layer
	my_id = network_layer.get_my_id()
	slots = [slot1, slot2, slot3, slot4]

	ENetManager.player_list_updated.connect(_on_player_list_updated)
	leave_button.pressed.connect(_on_leave_pressed)
	ENetManager.disconnected_from_server.connect(back_to_main_menu)
	ENetManager.back_to_main_menu.connect(back_to_main_menu)


	if network_layer.is_host():
		is_host = true
		current_players = ENetManager.get_player_list()
		_update_player_list()

	_set_role_label()
	_set_team_label(my_team)


func _set_role_label() -> void:
	if is_host:
		role_label.text = "You are: Host (Player %d)" % my_id
	else:
		role_label.text = "You are: Client (Player %d)" % my_id


func _set_team_label(team_number: int) -> void:
	if team_number == -1:
		team_label.text = "Team: Unassigned"
	else:
		team_label.text = "Team: %d" % team_number


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


func _on_player_list_updated(players: Array[int] = []):
	current_players = players.duplicate()
	_update_player_list()
	print("Lobby updated - Players: %s" % str(players))


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




func back_to_main_menu() -> void:
	change_scene("res://scenes/Network_Layer/main_menu.tscn")


## Helper Functions to Change Scenes
func change_scene(scene_path: String):
	## "res://scenes/Network_Layer/main_menu.tscn"
	get_tree().call_deferred("change_scene_to_file", scene_path)
