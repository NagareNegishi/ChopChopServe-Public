## Auto loaded as: ENetManager
extends Node

signal player_list_updated(players: Array[int])
signal team_assigned(team1: Array[int], team2: Array[int])
signal disconnected_from_server()
signal back_to_main_menu()


const MAX_WAITING : float = 120.0
var enet_layer: ENetNetworkLayer
var player_list: Array[int] = []
var team1: Array[int] = []
var team2: Array[int] = []
var offline_players: Array[int] = []
var game_paused: bool = false


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
	print("Player joined: " + str(player_id))
	# Only the host handles player management
	if not enet_layer.is_host():
		return
	# case client coming back from disconnection
	if player_id in offline_players:
		offline_players.erase(player_id)
		print("Player " + str(player_id) + " reconnected!")
		if offline_players.is_empty():
			print("Game resumed.")
			game_paused = false
			# need actual logic here !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	# case new client joining
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
	if player_id not in offline_players:
		offline_players.append(player_id)
	if enet_layer.is_host():
		# print("Game paused due to player disconnection.")
		game_paused = true
		# need actual logic here !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


## Clear all game state since host is gone
func _on_disconnected_from_server():
	print("Disconnected from server - returning to menu")
	clear_player_list()
	game_paused = false
	disconnected_from_server.emit()


## Handle incoming data
func _on_data_received(from_id: int, data: Dictionary):
	# print("DEBUG: Received data from : ", from_id, ": ", data, "I am : ", enet_layer.get_my_id())
	if data.get("type") == "player_list_update":
		player_list = data.players
		player_list_updated.emit(player_list)

	elif data.get("type") == "player_leaving_intentionally":
		if enet_layer.is_host() and data.has("player_id"):
			player_leaves_intentionally(data.player_id)

	elif data.get("type") == "you_are_leaving":
		back_to_main_menu.emit()
		await get_tree().create_timer(0.1).timeout
		enet_layer.leave_game()




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
