# lobby_network.gd
extends Control
class_name LobbyNetwork

enum SlotPosition {
	TEAM1_SLOT1,
	TEAM1_SLOT2,
	TEAM2_SLOT1,
	TEAM2_SLOT2,
	UNASSIGNED_LEFT,
	UNASSIGNED_CENTER,
	UNASSIGNED_RIGHT
}

# Unassigned area constants
const UNASSIGNED_Y = 300
const UNASSIGNED_SPACING = 210

@onready var role_label: Label = $RoleLabel
@onready var team_label: Label = $TeamLabel
@onready var ip_label: Label = $IPLabel
@onready var code_label: Label = $CodeText
@onready var vs_label: Label = $VSLabel
@onready var buttons_container: Container = $ControlContainer
@onready var shuffle_button: Button = $ControlContainer/ShuffleButton
@onready var start_button: Button = $ControlContainer/StartButton
@onready var leave_button: Button = $ControlContainer/LeaveButton

@onready var slot_1: PlayerSlot = $Team1Slot1
@onready var slot_2: PlayerSlot = $Team2Slot1
@onready var slot_3: PlayerSlot = $Team1Slot2
@onready var slot_4: PlayerSlot = $Team2Slot2

var network_layer: ENetNetworkLayer
var slot_scene: PackedScene
var current_players: Array[int] = []
var slots: Array[PlayerSlot]
var team_slot_positions: Dictionary = {}
var unassigned_positions: Dictionary = {}
var is_host: bool = false
var my_id: int = -1
var my_team: int = -1
var is_local: bool = true


## Setup
func _ready():
	network_layer = ENetManager.enet_layer
	my_id = network_layer.get_my_id()
	slots = [slot_1, slot_2, slot_3, slot_4]
	# Capture designer's positions from the actual slot nodes
	team_slot_positions = {
		SlotPosition.TEAM1_SLOT1: {"pos": slot_1.position, "rot": slot_1.rotation},
		SlotPosition.TEAM1_SLOT2: {"pos": slot_3.position, "rot": slot_3.rotation},
		SlotPosition.TEAM2_SLOT1: {"pos": slot_2.position, "rot": slot_2.rotation},
		SlotPosition.TEAM2_SLOT2: {"pos": slot_4.position, "rot": slot_4.rotation},
	}
	print(team_slot_positions)
	# Define unassigned positions
	var center_x = get_viewport_rect().size.x / 2.0
	var slot_size = slot_1.size
	var slot_half_width = slot_size.x / 2.0
	unassigned_positions = {
		SlotPosition.UNASSIGNED_LEFT: {
			"pos": Vector2(center_x - UNASSIGNED_SPACING - slot_half_width, UNASSIGNED_Y),
			"rot": 0.0
		},
		SlotPosition.UNASSIGNED_CENTER: {
			"pos": Vector2(center_x - slot_half_width, UNASSIGNED_Y),
			"rot": 0.0
		},
		SlotPosition.UNASSIGNED_RIGHT: {
			"pos": Vector2(center_x + UNASSIGNED_SPACING - slot_half_width, UNASSIGNED_Y),
			"rot": 0.0
		},
	}
	print(unassigned_positions)
	move_slot_to_position(slot_2, SlotPosition.UNASSIGNED_LEFT, false)
	move_slot_to_position(slot_3, SlotPosition.UNASSIGNED_CENTER, false)
	move_slot_to_position(slot_4, SlotPosition.UNASSIGNED_RIGHT, false)
	ENetManager.player_list_updated.connect(_on_player_list_updated)
	# ENetManager.disconnected_from_server.connect(_back_to_main_menu)
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
	_set_code_label()
	_set_ip_label()
	_set_buttons()
	_activate_start_game(false)



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


## Set ip Label
func _set_ip_label() -> void:
	if is_host:
		ip_label.show()
		ip_label.text = "%s" % network_layer.get_connection_info()
		if not is_local:
			ENetManager.show_notification(
				"Reachability: " + network_layer.Reachability.keys()[network_layer.reachability],
				3.0
			)
	else:
		ip_label.hide()


## Set code Label
func _set_code_label() -> void:
	if is_host:
		code_label.show()
		if network_layer.room_code == "":
			code_label.text = "Using local network, the best way to connect you is:"
		else:
			code_label.text = "CODE: %s" % network_layer.room_code
			is_local = false
	else:
		code_label.hide()


## Set Buttons
func _set_buttons() -> void:
	shuffle_button.visible = is_host
	start_button.visible = is_host
	shuffle_button.disabled = true
	start_button.disabled = true


## Update Player List
func _update_player_list():
	for i in range(4):
		var slot = slots[i]
		if i < current_players.size():
			var player_id = current_players[i]
			var player_name = "Player %d" % (i + 1)
			if player_id == my_id:
				player_name += " (You)"
				slot.set_as_local_player()
			slot.set_player({
				"name": player_name,
				"ID": player_id
			})
			slot.visible = true

			# if slot.current_team == PlayerSlot.Team.UNASSIGNED:
			# 	move_slot_to_position(slot, SlotPosition.TEAM2_SLOT2, true)







			if is_host and player_id != my_id:
				slot.show_kick_button()
		else:
			slot.set_player({"name": "Waiting..."})
			slot.visible = false


## Signal Handlers from ENetManager
func _on_player_list_updated(players: Array[int] = []):
	current_players = players.duplicate()
	_update_player_list()
	Debug.net_log("Player list updated: %s" % str(current_players))
	_activate_start_game(false)
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


## Signal Handlers from ENetManager, assign teams and display
func _on_team_assigned(team1: Array[int], team2: Array[int]) -> void:
	if my_id in team1:
		my_team = 1
	elif my_id in team2:
		my_team = 2
	else:
		my_team = -1
	_set_team_label(my_team)
	_activate_start_game(true)


## Activate or Deactivate Start Game UI
## @param activate: If true, show VS label and enable start button if host
func _activate_start_game(activate: bool) -> void:
	if activate:
		vs_label.show()
	else:
		vs_label.hide()
	if is_host:
		start_button.disabled = not ENetManager.can_start_game()


## Start Game
func _start_game() -> void:
	buttons_container.hide()
##----------------------------------------------------------------------------------
	# Actual scene
	# SceneManager.change_scene(SceneManager.Scene.LOBBY)
	# Test scene
	SceneManager.change_scene(SceneManager.Scene.EMMA_TEST)

##----------------------------------------------------------------------------------


## Back to Main Menu
func _back_to_main_menu() -> void:
	SceneManager.change_scene(SceneManager.Scene.MAIN_MENU)


## Move a slot to a specific position
## @param slot: The PlayerSlot to move
## @param target_position: SlotPosition enum value
## @param animate: Whether to animate the movement
## @return: True if moved successfully, False if position occupied
func move_slot_to_position(slot: PlayerSlot, target_position: SlotPosition, animate: bool = true) -> bool:
	# Get target position data
	var position_data: Dictionary
	if target_position in team_slot_positions:
		position_data = team_slot_positions[target_position]
	elif target_position in unassigned_positions:
		position_data = unassigned_positions[target_position]
	else:
		push_error("Invalid slot position: %d" % target_position)
		return false
	
	var target_pos = position_data["pos"]
	var target_rot = position_data["rot"]
	
	# Check if another slot is already at this position
	for other_slot in slots:
		if other_slot == slot:
			continue  # Skip self
		if other_slot.position.distance_to(target_pos) < 10.0:  # Within 10 pixels = occupied
			Debug.net_log("Position %d is already occupied by another slot" % target_position)
			return false
	
	# Position is free, move the slot
	if animate:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(slot, "position", target_pos, 0.3).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(slot, "rotation", target_rot, 0.3).set_trans(Tween.TRANS_CUBIC)
	else:
		slot.position = target_pos
		slot.rotation = target_rot
	
	Debug.net_log("Moved slot to position %d" % target_position)
	return true
