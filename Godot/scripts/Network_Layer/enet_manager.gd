## Auto loaded as: ENetManager



#TODO: Do not concern the disconnected player,
# no need to track offline player, once disconnected, they are gone
# if someone disconnected -> don't wait -> back to lobby directly


extends Node

enum GameProgress {
	LOBBY,
	IN_GAME,
	PAUSED
}

signal player_list_updated(players: Array[int])
signal team_assigned(team1: Array[int], team2: Array[int])
signal disconnected_from_server()
signal back_to_main_menu()
signal game_started()
signal game_paused(is_paused: bool)


const MAX_WAITING : float = 120.0
var enet_layer: ENetNetworkLayer
var player_list: Array[int] = []
var team1: Array[int] = []
var team2: Array[int] = []
var offline_players: Array[int] = []
var current_state: GameProgress = GameProgress.LOBBY


## Setup
func _ready():
	enet_layer = ENetNetworkLayer.new()
	add_child(enet_layer)
	enet_layer.player_joined.connect(_on_player_joined)
	enet_layer.player_left.connect(_on_player_left)
	enet_layer.disconnected.connect(_on_disconnected_from_server)
	enet_layer.data_received.connect(_on_data_received)


## Update Player List when a player joins, and host shares it
## @param player_id: The ID of the player who joined
func _on_player_joined(player_id: int):
	# Only the host handles player management
	if not enet_layer.is_host():
		return

	# case client coming back from disconnection
	if player_id in offline_players:
		offline_players.erase(player_id)
		print("Player " + str(player_id) + " reconnected!")
		if offline_players.is_empty():
			print("Game resumed.")
			current_state = GameProgress.IN_GAME
			enet_layer.broadcast_except(enet_layer.get_my_id(), {
				"type": "game_paused",
				"is_paused": false
			})
			game_paused.emit(false)
		return

	# case new client joining after the game has started
	if current_state == GameProgress.IN_GAME:
		print("Sorry, you cannot join the game in progress.")
		enet_layer.send_to(player_id, {
		"type": "you_are_leaving"
		})
		return

	# case new client joining in lobby
	if player_id not in player_list:
		player_list.append(player_id)
		enet_layer.broadcast_except(enet_layer.get_my_id(), {
			"type": "player_list_update",
			"players": player_list
		})
		player_list_updated.emit(player_list)


## Update Player List when a player intentionally leaves, and host shares it
## This function can be use for kicking players too
## @param player_id: The ID of the player who left
func player_leaves_intentionally(player_id: int):
	if not enet_layer.is_host():
		push_warning("player_leaves_intentionally() should only be called by host")
		return
	if player_id == -1:
		print("Player can not leave - Invalid player ID")
		return
	print("Player left: " + str(player_id))
	player_list.erase(player_id)
	team1.erase(player_id)
	team2.erase(player_id)
	offline_players.erase(player_id)
	enet_layer.broadcast_except(enet_layer.get_my_id(), {
		"type": "player_list_update",
		"players": player_list
	})

	# If host is leaving, shut down the server
	if player_id == enet_layer.get_my_id():
		clear_player_list()
		back_to_main_menu.emit()
		enet_layer.leave_game()
	else:
		enet_layer.send_to(player_id, {
		"type": "you_are_leaving"
		})
	player_list_updated.emit(player_list)


## Update Player List when a player accidentally leaves, and host shares it
## @param player_id: The ID of the player who left
func _on_player_left(player_id: int):
	if player_id not in player_list:
		return
	if player_id not in offline_players:
		offline_players.append(player_id)
	if enet_layer.is_host() and current_state == GameProgress.IN_GAME:
		print("Game paused due to player disconnection!")
		current_state = GameProgress.PAUSED
		enet_layer.broadcast_except(enet_layer.get_my_id(), {
			"type": "game_paused",
			"is_paused": true
		})
		game_paused.emit(true)


## Clear all game state
func _on_disconnected_from_server():
	print("Disconnected from server - returning to menu")
	clear_player_list()
	current_state = GameProgress.LOBBY
	disconnected_from_server.emit()


## Handle incoming data
func _on_data_received(_from_id: int, data: Dictionary):
	# print("DEBUG: Received data from : ", from_id, ": ", data, "I am : ", enet_layer.get_my_id())
	match data.get("type"):
		"player_list_update":
			player_list = data.players
			player_list_updated.emit(player_list)

		"player_leaving_intentionally":
			if enet_layer.is_host() and data.has("player_id"):
				player_leaves_intentionally(data.player_id)

		"you_are_leaving":
			back_to_main_menu.emit()
			await get_tree().create_timer(0.1).timeout
			enet_layer.leave_game()

		"team_assignment":
			team1 = data.team1
			team2 = data.team2
			team_assigned.emit(team1, team2)
		
		"game_starting":
			current_state = GameProgress.IN_GAME
			game_started.emit()

		"game_paused":
			if (data.is_paused):
				current_state = GameProgress.PAUSED
			else:
				current_state = GameProgress.IN_GAME
			game_paused.emit(data.is_paused)

		_:
			print("Unknown message type: ", data.get("type"))


## Get the ID of the current player
## @return: The ID of the current player
func get_my_id() -> int:
	return enet_layer.get_my_id()


## Check if the current player is the host
## @return: True if the current player is the host, false otherwise
func is_host() -> bool:
	return enet_layer.is_host()


## Get the team ID of the local player
func get_my_team() -> int:
	if get_my_id() in team1:
		return 1
	elif get_my_id() in team2:
		return 2
	return 0


## Get the team of a given player
## @param player_id: The ID of the player
## @return: The team ID of the player, or 0 if not in a team
func get_team(player_id: int) -> int:
	if player_id in team1:
		return 1
	elif player_id in team2:
		return 2
	return 0


## Get current player list
## @return: The current list of players
func get_player_list() -> Array[int]:
	return player_list.duplicate()


## Get current team 1
## @return: The current list of players in team 1
func get_team1() -> Array[int]:
	return team1.duplicate()


## Get current team 2
## @return: The current list of players in team 2
func get_team2() -> Array[int]:
	return team2.duplicate()


## Clear player list
func clear_player_list():
	player_list.clear()
	team1.clear()
	team2.clear()
	offline_players.clear()


## Shuffle players into two teams and broadcast the assignment
func shuffle_players():
	if not enet_layer.is_host():
		push_warning("shuffle_players() should only be called by host")
		return
	if player_list.size() % 2 != 0:
		push_warning("Cannot shuffle players with odd number of players.")
		return
	team1.clear()
	team2.clear()
	var shuffled = player_list.duplicate()
	shuffled.shuffle()
	var team_size = shuffled.size() / 2
	team1 = shuffled.slice(0, team_size)
	team2 = shuffled.slice(team_size)
	enet_layer.broadcast_except(enet_layer.get_my_id(), {
		"type": "team_assignment",
		"team1": team1,
		"team2": team2
	})
	team_assigned.emit(team1, team2)


## Check if game can start
## @return: True if game can start, false otherwise
func can_start_game() -> bool:
	return team1.size() == team2.size() and not team1.is_empty()


## Start the game
func start_game() -> void:
	if not can_start_game():
		push_warning("Cannot start game - teams not ready!")
		return
	current_state = GameProgress.IN_GAME
	enet_layer.broadcast_except(enet_layer.get_my_id(), {
		"type": "game_starting"
	})
	game_started.emit()


