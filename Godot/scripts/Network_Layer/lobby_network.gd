# lobby_network.gd
extends Control
class_name LobbyNetwork


# Export team slot positions for designer to modify
@export_group("Team 1 Slots")
@export var team1_slot1_pos: Vector2 = Vector2(102, 138)
@export var team1_slot1_rot: float = -0.035
@export var team1_slot2_pos: Vector2 = Vector2(139, 377)
@export var team1_slot2_rot: float = 0.035

@export_group("Team 2 Slots")
@export var team2_slot1_pos: Vector2 = Vector2(889, 136)
@export var team2_slot1_rot: float = 0.035
@export var team2_slot2_pos: Vector2 = Vector2(839, 378)
@export var team2_slot2_rot: float = -0.035

@export_group("Unassigned Slots")
@export var unassigned_base_y: float = 300.0
@export var unassigned_positions: Array[Vector2] = [
	Vector2(186, 300),
	Vector2(396, 300),
	Vector2(606, 300),
	Vector2(816, 300)
]

@onready var role_label: Label = $RoleLabel
@onready var team_label: Label = $TeamLabel
@onready var ip_label: Label = $IPLabel
@onready var code_label: Label = $CodeText
@onready var vs_label: Label = $VSLabel
@onready var buttons_container: Container = $ControlContainer
@onready var shuffle_button: Button = $ControlContainer/ShuffleButton
@onready var start_button: Button = $ControlContainer/StartButton
@onready var leave_button: Button = $ControlContainer/LeaveButton

var network_layer: ENetNetworkLayer
var current_players: Array[int] = []
var slot_scene: PackedScene = preload("res://scenes/Network_Layer/player_slot.tscn")
var player_slots: Dictionary = {}  # {player_id: PlayerSlot}
var slot_occupied: Array[bool] = [false, false, false, false]
var animation_duration: float = 0.3
var is_host: bool = false
var my_id: int = -1
var my_team: int = -1
var is_local: bool = true


## Setup
func _ready():
	network_layer = ENetManager.enet_layer
	my_id = network_layer.get_my_id()
	is_host = network_layer.is_host()
	ENetManager.player_list_updated.connect(_on_player_list_updated)
	# ENetManager.disconnected_from_server.connect(_back_to_main_menu)
	ENetManager.back_to_main_menu.connect(_back_to_main_menu)
	ENetManager.team_assigned.connect(_on_team_assigned)
	ENetManager.player_assigned.connect(_on_player_assigned)
	ENetManager.game_started.connect(_start_game)
	leave_button.pressed.connect(_on_leave_pressed)
	shuffle_button.pressed.connect(ENetManager.shuffle_players)
	start_button.pressed.connect(ENetManager.start_game)

	current_players = ENetManager.get_player_list()
	_update_player_list()
	_set_role_label()
	_set_team_label(my_team)
	_set_code_label()
	_set_ip_label()
	_set_buttons()
	_activate_start_game(false)
	if not is_host:
		_request_current_slots.rpc_id(1, my_id)


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


## Create or remove player slots to match current players
func _update_player_list():
	var old_players = player_slots.keys()
	# Remove slots for players who left
	for player_id in old_players:
		if player_id not in current_players:
			_remove_player_slot(player_id)
	# Create slots for new players
	for player_id in current_players:
		if player_id not in player_slots:
			_create_player_slot(player_id)


## Create a new player slot
## @param player_id: The ID of the player to create a slot for
func _create_player_slot(player_id: int):
	if not slot_scene:
		push_error("Slot scene not assigned")
		return

	# Instantiate slot
	var slot: PlayerSlot = slot_scene.instantiate()
	add_child(slot)
	player_slots[player_id] = slot

	# Setup slot
	var player_name = ""
	if player_id == my_id:
		player_name = "You"
		slot.set_as_local_player(true)
		slot._check_team_buttons()
	else:
		slot.set_as_local_player(false)
		slot._hide_team_buttons()
		if is_host:
			slot.show_kick_button()
	slot.set_player({
		"name": player_name,
		"ID": player_id
	})
	_position_slot(slot, player_id)


## Identify appropriate position for the new slot and position it
## @param slot: The PlayerSlot instance to position
## @param player_id: The ID of the player this slot represents
func _position_slot(slot: PlayerSlot, player_id: int) -> void:
	# Check for available unassigned slot
	if is_host:
		var unassigned_index = _find_next_available_slot()
		if unassigned_index == -1:
			# Should handle this more gracefully, but it should never happen
			assert(false, "No available slot positions for new player %d" % player_id)
			return
		slot_occupied[unassigned_index] = true
		slot.slot_index = unassigned_index

		# Position in unassigned area
		_position_unassigned_slots(slot, unassigned_index)
		_sync_slot_position.rpc(player_id, unassigned_index)
		Debug.net_log("Host: Created slot for player %d at position %d" % [player_id, unassigned_index])
	else:
		slot.visible = false


## Find the next available slot position (HOST ONLY)
## @return: The index of the next available slot, or -1 if none available
func _find_next_available_slot() -> int:
	for i in range(slot_occupied.size()):
		if not slot_occupied[i]:
			return i
	return -1


## Actually position the slot in the unassigned area
## @param slot: The PlayerSlot instance to position
## @param slot_index: The index of the unassigned position to use
func _position_unassigned_slots(slot: PlayerSlot, slot_index: int) -> void:
	if slot_index >= 0 and slot_index < unassigned_positions.size():
		slot.position = unassigned_positions[slot_index]
		slot.rotation = 0.0
		slot.visible = true


## Client: Sync slot position from host
## @param player_id: The ID of the player whose slot is being positioned
## @param slot_index: The index of the unassigned position to use
@rpc("authority", "call_remote", "reliable")
func _sync_slot_position(player_id: int, slot_index: int):
	Debug.net_log("Client: Received position for player %d: slot %d" % [player_id, slot_index])
	slot_occupied[slot_index] = true
	# Position the slot if it exists
	if player_id in player_slots:
		var slot = player_slots[player_id]
		slot.slot_index = slot_index
		_position_unassigned_slots(slot, slot_index)


## Remove a player slot
## @param player_id: The ID of the player whose slot should be removed
func _remove_player_slot(player_id: int):
	if player_id in player_slots:
		var slot = player_slots[player_id]
		var slot_index = slot.slot_index

#---------------------------------

# add team alignment logic here



		var team = slot.get_team()

#-------------------------------------
		slot.queue_free()
		player_slots.erase(player_id)
		if is_host and slot_index >= 0 and slot_index < slot_occupied.size():
			slot_occupied[slot_index] = false
			_sync_slot_freed(slot_index)
		Debug.net_log("Removed slot for player %d" % player_id)


## Client: Sync occupied slot to what host has freed
## @param slot_index: The index of the slot that is now free
@rpc("authority", "call_remote", "reliable")
func _sync_slot_freed(slot_index: int):
	Debug.net_log("Client: Slot %d is now free" % slot_index)
	slot_occupied[slot_index] = false


## RPC: Client requests full slot state from host
@rpc("any_peer", "call_remote", "reliable")
func _request_current_slots(client_id: int):
	if not is_host:
		return
	# Send current slot positions for all players
	for player_id in player_slots:
		var slot = player_slots[player_id]
		if slot.slot_index >= 0:
			_sync_slot_position.rpc_id(client_id, player_id, slot.slot_index)

	# Send current team assignments
	var team1 = ENetManager.get_team1()
	var team2 = ENetManager.get_team2()
	for i in range(team1.size()):
		var player_id = team1[i]
		_sync_team_assignment.rpc_id(client_id, player_id, 1, i + 1)
	for i in range(team2.size()):
		var player_id = team2[i]
		_sync_team_assignment.rpc_id(client_id, player_id, 2, i + 1)


## Signal Handler: Player list updated
## @param players: The updated list of player IDs
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


## Signal Handler: Player assigned to team
## @param player_id: The ID of the player assigned
## @param team: The team number assigned (1 or 2)
## @param number: The slot number within the team (1 or 2)
func _on_player_assigned(player_id: int, team: int, number: int, animate: bool = true) -> void:
	if player_id not in player_slots:
		push_warning("Player %d not found in slots!" % player_id)
		return
	var slot = player_slots[player_id]
	slot.set_team(team)
	var target_data = _get_team_slot_transform(team, number)
	if target_data.is_empty():
		push_warning("Invalid team/slot: %d/%d" % [team, number])
		return
	_move_slot_to_transform(slot, target_data.pos, target_data.rot, animate)
	Debug.net_log("Moved player %d to team %d slot %d" % [player_id, team, number])
	if player_id == my_id:
		my_team = team
		_set_team_label(my_team)
	if ENetManager.can_start_game():
		_activate_start_game(true)


## Sync team assignment from host to client
## @param player_id: The ID of the player assigned
## @param team: The team number assigned (1 or 2)
## @param number: The slot number within the team (1 or 2)
@rpc("authority", "call_remote", "reliable")
func _sync_team_assignment(player_id: int, team: int, number: int):
	Debug.net_log("Client: Syncing team assignment for player %d: team %d, slot %d" % [player_id, team, number])
	_on_player_assigned(player_id, team, number, false)


## Get team slot transform data
## @param team: The team number (1 or 2)
## @param slot_num: The slot number within the team (1 or 2)
## @return: where to position the slot
func _get_team_slot_transform(team: int, slot_num: int) -> Dictionary:
	if team == 1 and slot_num == 1:
		return {"pos": team1_slot1_pos, "rot": team1_slot1_rot}
	elif team == 1 and slot_num == 2:
		return {"pos": team1_slot2_pos, "rot": team1_slot2_rot}
	elif team == 2 and slot_num == 1:
		return {"pos": team2_slot1_pos, "rot": team2_slot1_rot}
	elif team == 2 and slot_num == 2:
		return {"pos": team2_slot2_pos, "rot": team2_slot2_rot}
	return {}


## Move slot to target transform
## @param slot: The PlayerSlot instance to move
## @param target_pos: The target position to move to
## @param target_rot: The target rotation to rotate to
## @param animation: If true, animate the movement; if false, move instantly
func _move_slot_to_transform(slot: PlayerSlot, target_pos: Vector2, target_rot: float, animation: bool) -> void:
	if animation:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(slot, "position", target_pos, animation_duration).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(slot, "rotation", target_rot, animation_duration).set_trans(Tween.TRANS_CUBIC)
	else:
		slot.position = target_pos
		slot.rotation = target_rot


## Signal Handlers from ENetManager, assign teams and display
## @param team1: Array of player IDs in team 1
## @param team2: Array of player IDs in team 2
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

	SceneManager.change_scene(SceneManager.Scene.LOBBY)

##----------------------------------------------------------------------------------


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


## Back to Main Menu
func _back_to_main_menu() -> void:
	SceneManager.change_scene(SceneManager.Scene.MAIN_MENU)
