# lobby_network.gd
extends Control
class_name LobbyNetwork

enum SlotPosition {
	TEAM1_SLOT1,
	TEAM1_SLOT2,
	TEAM2_SLOT1,
	TEAM2_SLOT2,
	UNASSIGNED1,
	UNASSIGNED2,
	UNASSIGNED3,
	UNASSIGNED4
}
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

# # Unassigned area constants
# const UNASSIGNED_Y = 300
# const UNASSIGNED_SPACING = 210

@onready var role_label: Label = $RoleLabel
@onready var team_label: Label = $TeamLabel
@onready var ip_label: Label = $IPLabel
@onready var code_label: Label = $CodeText
@onready var vs_label: Label = $VSLabel
@onready var buttons_container: Container = $ControlContainer
@onready var shuffle_button: Button = $ControlContainer/ShuffleButton
@onready var start_button: Button = $ControlContainer/StartButton
@onready var leave_button: Button = $ControlContainer/LeaveButton

# @onready var slot_1: PlayerSlot = $Team1Slot1
# @onready var slot_2: PlayerSlot = $Team2Slot1
# @onready var slot_3: PlayerSlot = $Team1Slot2
# @onready var slot_4: PlayerSlot = $Team2Slot2

var network_layer: ENetNetworkLayer
var current_players: Array[int] = []
var slot_scene: PackedScene = preload("res://scenes/Network_Layer/player_slot.tscn")
var player_slots: Dictionary = {}  # {player_id: PlayerSlot}
# var slots: Array[PlayerSlot]
# var team_slot_positions: Dictionary = {}
# var unassigned_positions: Dictionary = {}
# var player_slot_positions: Dictionary = {}  # {player_id: {team: int, slot_number: int}}
var is_host: bool = false
var my_id: int = -1
var my_team: int = -1
var is_local: bool = true


## Setup
func _ready():
	network_layer = ENetManager.enet_layer
	my_id = network_layer.get_my_id()
	is_host = network_layer.is_host()
	# _set_slots()
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


# ## Setup slot references and positions
# func _set_slots():
# 	slots = [slot_1, slot_2, slot_3, slot_4]
# 	# Capture designer's positions from the actual slot nodes
# 	team_slot_positions = {
# 		SlotPosition.TEAM1_SLOT1: {"pos": slot_1.position, "rot": slot_1.rotation},
# 		SlotPosition.TEAM1_SLOT2: {"pos": slot_3.position, "rot": slot_3.rotation},
# 		SlotPosition.TEAM2_SLOT1: {"pos": slot_2.position, "rot": slot_2.rotation},
# 		SlotPosition.TEAM2_SLOT2: {"pos": slot_4.position, "rot": slot_4.rotation},
# 	}
# 	print("Team slot positions: %s" % str(team_slot_positions))
# 	# Define positions for unassigned slots
# 	var center_x = get_viewport_rect().size.x / 2.0
# 	var slot_size = slot_1.size
# 	var slot_half_width = slot_size.x / 2.0
# 	unassigned_positions = {
# 		SlotPosition.UNASSIGNED1: {
# 			"pos": Vector2(center_x - (UNASSIGNED_SPACING * 1.5) - slot_half_width, UNASSIGNED_Y),
# 			"rot": 0.0
# 		},
# 		SlotPosition.UNASSIGNED2: {
# 			"pos": Vector2(center_x - (UNASSIGNED_SPACING * 0.5) - slot_half_width, UNASSIGNED_Y),
# 			"rot": 0.0
# 		},
# 		SlotPosition.UNASSIGNED3: {
# 			"pos": Vector2(center_x + (UNASSIGNED_SPACING * 0.5) - slot_half_width, UNASSIGNED_Y),
# 			"rot": 0.0
# 		},
# 		SlotPosition.UNASSIGNED4: {
# 			"pos": Vector2(center_x + (UNASSIGNED_SPACING * 1.5) - slot_half_width, UNASSIGNED_Y),
# 			"rot": 0.0
# 		},
# 	}
# 	print("Unassigned slot positions: %s" % str(unassigned_positions))
# 	# Initially move all slots to unassigned positions
# 	move_slot_to_position(slot_1, SlotPosition.UNASSIGNED1, false)
# 	move_slot_to_position(slot_2, SlotPosition.UNASSIGNED2, false)
# 	move_slot_to_position(slot_3, SlotPosition.UNASSIGNED3, false)
# 	move_slot_to_position(slot_4, SlotPosition.UNASSIGNED4, false)


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


## Update player list - create/remove slots as needed
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
	
	Debug.net_log("Player slots updated: %s" % str(player_slots.keys()))


## Create a new player slot
func _create_player_slot(player_id: int):
	if not slot_scene:
		push_error("Slot scene not assigned!")
		return
	
	var slot: PlayerSlot = slot_scene.instantiate()
	add_child(slot)
	player_slots[player_id] = slot
	
	# Set player data
	var player_index = current_players.find(player_id)
	var player_name = "Player %d" % (player_index + 1)
	if player_id == my_id:
		player_name += " (You)"
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
	
	# Position in unassigned area (no animation for initial placement)
	var unassigned_index = min(player_index, unassigned_positions.size() - 1)
	if unassigned_index >= 0 and unassigned_index < unassigned_positions.size():
		slot.position = unassigned_positions[unassigned_index]
		slot.rotation = 0.0
	
	slot.visible = true
	Debug.net_log("Created slot for player %d at unassigned position %d" % [player_id, unassigned_index])


## Remove a player slot
func _remove_player_slot(player_id: int):
	if player_id in player_slots:
		player_slots[player_id].queue_free()
		player_slots.erase(player_id)
		Debug.net_log("Removed slot for player %d" % player_id)



# ## Update Player List
# func _update_player_list():
# 	for i in range(4):
# 		var slot = slots[i]
# 		if i < current_players.size():
# 			var player_id = current_players[i]
# 			var player_name = "Player %d" % (i + 1)
# 			if player_id == my_id:
# 				player_name += " (You)"
# 				slot.set_as_local_player(true)
# 				slot._check_team_buttons()
# 			else:
# 				slot.set_as_local_player(false)
# 				slot._hide_team_buttons()
# 			slot.set_player({
# 				"name": player_name,
# 				"ID": player_id
# 			})
# 			slot.visible = true

# 			if is_host and player_id != my_id:
# 				slot.show_kick_button()
# 		else:
# 			slot.set_player({"name": "Waiting..."})
# 			slot.visible = false


# ## Handle when a player is removed from the list
# func _handle_player_removed(player_id: int):
# 	if is_host:
# 		player_slot_positions.erase(player_id)
# 		Debug.net_log("Player %d removed, current positions: %s" % [player_id, str(player_slot_positions)])
# 	# Find the slot with this player and clear it
# 	for slot in slots:
# 		if slot.player_data.get("ID", -1) == player_id:
# 			slot.visible = false
# 			slot.set_player({"name": "Waiting...", "ID": -1})
# 			slot._hide_team_buttons()
# 			break


# ## Handle when a new player is added to the list
# func _handle_player_added(player_id: int):
# 	# Find first available unassigned slot
# 	var player_index = current_players.find(player_id)
# 	if player_index >= 0 and player_index < 4:
# 		var slot = slots[player_index]
# 		var unassigned_positions_array = [
# 			SlotPosition.UNASSIGNED1,
# 			SlotPosition.UNASSIGNED2,
# 			SlotPosition.UNASSIGNED3,
# 			SlotPosition.UNASSIGNED4
# 		]
# 		move_slot_to_position(slot, unassigned_positions_array[player_index], false)
# 		var player_name = "Player %d" % (player_index + 1)
# 		if player_id == my_id:
# 			player_name += " (You)"
# 			slot.set_as_local_player(true)
# 			slot._check_team_buttons()
# 		else:
# 			slot.set_as_local_player(false)
# 			slot._hide_team_buttons()
# 		slot.set_player({
# 			"name": player_name,
# 			"ID": player_id
# 		})
# 		slot.visible = true

# 		if is_host and player_id != my_id:
# 			slot.show_kick_button()


# ## Signal Handlers from ENetManager
# func _on_player_list_updated(players: Array[int] = []):
# 	var old_players = current_players.duplicate()
# 	current_players = players.duplicate()
# 	# Detect what changed
# 	var players_added: Array[int] = []
# 	var players_removed: Array[int] = []
# 	# Find new players
# 	for player_id in current_players:
# 		if not player_id in old_players:
# 			players_added.append(player_id)
# 	# Find removed players
# 	for player_id in old_players:
# 		if not player_id in current_players:
# 			players_removed.append(player_id)
# 	# Handle removed players first
# 	for player_id in players_removed:
# 		_handle_player_removed(player_id)
# 	# Handle added players
# 	for player_id in players_added:
# 		_handle_player_added(player_id)
	
# 	# _update_player_list()
# 	Debug.net_log("Player list updated: %s" % str(current_players))
# 	_activate_start_game(false)
# 	if is_host:
# 		start_button.disabled = true
# 		if current_players.size() % 2 == 0:
# 			shuffle_button.disabled = false
# 		else:
# 			shuffle_button.disabled = true

## Signal Handler: Player list updated
func _on_player_list_updated(players: Array[int] = []):
	current_players = players.duplicate()
	_update_player_list()
	_activate_start_game(false)
	
	if is_host:
		start_button.disabled = true
		if current_players.size() % 2 == 0 and current_players.size() > 0:
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


# ## Signal Handlers from ENetManager, assign players and display
# ## @param player_id: The ID of the player assigned
# ## @param team: The team number assigned (1 or 2)
# ## @param number: The slot number within the team (1 or 2)
# func _on_player_assigned(player_id: int, team: int, number: int) -> void:
# 	# Store position (host only)
# 	if is_host:
# 		player_slot_positions[player_id] = {"team": team, "slot_number": number}

# 	for slot in slots:
# 		var slot_id = slot.player_data.get("ID", -1)
# 		if slot_id == player_id:
# 			var target_position: SlotPosition
# 			if team == 1:
# 				if number == 1:
# 					target_position = SlotPosition.TEAM1_SLOT1
# 				elif number == 2:
# 					target_position = SlotPosition.TEAM1_SLOT2
# 				else:
# 					push_warning("Invalid slot number for team 1!")
# 					return
# 			elif team == 2:
# 				if number == 1:
# 					target_position = SlotPosition.TEAM2_SLOT1
# 				elif number == 2:
# 					target_position = SlotPosition.TEAM2_SLOT2
# 				else:
# 					push_warning("Invalid slot number for team 2!")
# 					return
# 			else:
# 				push_warning("Invalid team number!")
# 				return
# 			move_slot_to_position(slot, target_position,true)
# 			break


## Signal Handler: Player assigned to team
func _on_player_assigned(player_id: int, team: int, number: int) -> void:
	if player_id not in player_slots:
		push_warning("Player %d not found in slots!" % player_id)
		return
	
	var slot = player_slots[player_id]
	var target_data = _get_team_slot_transform(team, number)
	
	if target_data.is_empty():
		push_warning("Invalid team/slot: %d/%d" % [team, number])
		return
	
	_move_slot_to_transform(slot, target_data.pos, target_data.rot)
	Debug.net_log("Moved player %d to team %d slot %d" % [player_id, team, number])


## Get team slot transform data
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




@export var animate_movement: bool = true
@export var animation_duration: float = 0.3

## Move slot to target transform
func _move_slot_to_transform(slot: PlayerSlot, target_pos: Vector2, target_rot: float):
	if animate_movement:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(slot, "position", target_pos, animation_duration).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(slot, "rotation", target_rot, animation_duration).set_trans(Tween.TRANS_CUBIC)
	else:
		slot.position = target_pos
		slot.rotation = target_rot








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


# ## Move a slot to a specific position
# ## @param slot: The PlayerSlot to move
# ## @param target_position: SlotPosition enum value
# ## @param animate: Whether to animate the movement
# ## @return: True if moved successfully, False if position occupied
# func move_slot_to_position(slot: PlayerSlot, target_position: SlotPosition, animate: bool = true) -> bool:
# 	# Get target position data
# 	var position_data: Dictionary
# 	if target_position in team_slot_positions:
# 		position_data = team_slot_positions[target_position]
# 	elif target_position in unassigned_positions:
# 		position_data = unassigned_positions[target_position]
# 	else:
# 		push_error("Invalid slot position: %d" % target_position)
# 		return false
	
# 	var target_pos = position_data["pos"]
# 	var target_rot = position_data["rot"]
	
# 	# Check if another slot is already at this position
# 	for other_slot in slots:
# 		if other_slot == slot:
# 			continue  # Skip self
# 		if other_slot.position.distance_to(target_pos) < 10.0:  # Within 10 pixels = occupied
# 			Debug.net_log("Position %d is already occupied by another slot" % target_position)
# 			return false
	
# 	# Position is free, move the slot
# 	if animate:
# 		var tween = create_tween()
# 		tween.set_parallel(true)
# 		tween.tween_property(slot, "position", target_pos, 0.3).set_trans(Tween.TRANS_CUBIC)
# 		tween.tween_property(slot, "rotation", target_rot, 0.3).set_trans(Tween.TRANS_CUBIC)
# 	else:
# 		slot.position = target_pos
# 		slot.rotation = target_rot
	
# 	Debug.net_log("Moved slot to position %d" % target_position)
# 	return true




# ## Client requests position sync from host
# @rpc("any_peer", "call_remote", "reliable")
# func request_position_sync():
# 	if is_host:
# 		var requester_id = multiplayer.get_remote_sender_id()
# 		send_position_sync.rpc_id(requester_id, player_slot_positions)


# ## Host sends positions to client
# @rpc("authority", "call_remote", "reliable")
# func send_position_sync(positions: Dictionary):
# 	# Apply all received positions
# 	for player_id_key in positions:
# 		var player_id = int(player_id_key) if player_id_key is String else player_id_key
# 		var pos_data = positions[player_id_key]
# 		_move_player_to_team_slot(player_id, pos_data.team, pos_data.slot_number)


# ## Helper to move player to team slot
# func _move_player_to_team_slot(player_id: int, team: int, slot_num: int):
# 	for slot in slots:
# 		if slot.player_data.get("ID", -1) == player_id:
# 			var target_position: SlotPosition
# 			if team == 1 and slot_num == 1:
# 				target_position = SlotPosition.TEAM1_SLOT1
# 			elif team == 1 and slot_num == 2:
# 				target_position = SlotPosition.TEAM1_SLOT2
# 			elif team == 2 and slot_num == 1:
# 				target_position = SlotPosition.TEAM2_SLOT1
# 			elif team == 2 and slot_num == 2:
# 				target_position = SlotPosition.TEAM2_SLOT2
# 			else:
# 				return
# 			move_slot_to_position(slot, target_position, true)
# 			break