class_name ENetNetworkLayer
extends NetworkLayer

@export var port: int = 7000
# @export var bind_ip: String = "0.0.0.0"	## What to bind server to, but no use for Enet
@export var public_ip: String = ""	## What clients should connect to
@export var max_clients: int = 3 ## Maximum players -1, as player 1 is the host

var state: ConnectionState = ConnectionState.DISCONNECTED
var peer: ENetMultiplayerPeer
var my_id: int = -1


## Setup signals for player management
func _ready():
	# Connect to Godot's built-in multiplayer signals
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_disconnected_from_server)


## Create a server with default settings. Server is also player 1.
## @param max_players: Maximum number of players including host
## @return: True if server was created successfully
func create_game(max_players: int) -> bool:
	return create_game_with_ip(max_players, "")


## Create a server with custom public IP
## @param max_players: Maximum number of players including host
## @param host_public_ip: The public IP address that clients should connect to
## @return: True if server was created successfully
func create_game_with_ip(max_players: int, host_public_ip: String = "") -> bool:
	if state != ConnectionState.DISCONNECTED:
		push_warning("Already connected or connecting")
		return false
	if max_players <= 0:
		push_warning("Invalid max players")
		return false
	if max_players > max_clients + 1: # +1 for the host
		print("Max players clamped from %d to %d" % [max_players, max_clients + 1])
		max_players = max_clients + 1
	if host_public_ip != "":
		set_public_ip(host_public_ip)

	peer = ENetMultiplayerPeer.new()
	if peer.create_server(port, max_players - 1) == OK:
		multiplayer.multiplayer_peer = peer
		state = ConnectionState.HOST
		my_id = 1 # Host is always ID 1
		connected.emit()
		player_joined.emit(my_id)
		print("ENet server created on port %d, max players: %d" % [port, max_players])
		return true
	else:
		print("Failed to create ENet server: ")
		peer = null
		return false


## Join a server at the specified IP address (and port.)
## @param connection_info: can be "IP:PORT" or just "IP"
## @return: True if connection was successful
func join_game(connection_info: String) -> bool:
	if state != ConnectionState.DISCONNECTED:
		push_warning("Already connected or connecting")
		return false
	
	# Parse connection_info as "IP:PORT" or "IP"
	var parts: Array = connection_info.split(":")
	var target_ip: String = parts[0] if parts.size() > 0 else "127.0.0.1" # localhost
	if target_ip == "127.0.0.1":
		print("Warning: Using localhost fallback - this won't work for real multiplayer")
	var target_port: int = int(parts[1]) if parts.size() > 1 else port

	peer = ENetMultiplayerPeer.new()
	if peer.create_client(target_ip, target_port) == OK:
		multiplayer.multiplayer_peer = peer
		state = ConnectionState.CONNECTING
		print("Attempting to connect to %s:%d" % [target_ip, target_port])
		return true
	else:
		print("Failed to create ENet client")
		peer = null
		return false


## Disconnect from the server or stop hosting
func leave_game():
	if peer:
		if state == ConnectionState.HOST:
			# player_left.emit(my_id)
			print("Server shutdown")
		elif state == ConnectionState.CONNECTED:
			# disconnected.emit()
			print("Client with network ID: ", my_id, " is going to leave")
		else:
			print("Stop connecting")
		
		peer.close()
		multiplayer.multiplayer_peer = null
		peer = null
		state = ConnectionState.DISCONNECTED
		my_id = -1
		print(my_id," left game and disconnected")


## Handle peer connection (when someone joins)
## "A new peer has connected to the same network as me"
func _on_peer_connected(id: int):
	print("Peer connected: %d" % id)
	if state == ConnectionState.HOST:
		if multiplayer.get_peers().size() > max_clients:
			print("Maximum number of clients reached. Disconnecting new client.")
			multiplayer.disconnect_peer(id)
			return
		player_joined.emit(id)


## Handle peer disconnection (when someone leaves)
## "A peer that was part of our network has left"
func _on_peer_disconnected(id: int):
	print("Peer disconnected: %d" % id)
	if state == ConnectionState.HOST:
		player_left.emit(id)


## Handle connection failure (when join_game fails to connect)
func _on_connection_failed():
	print("Connection failed")
	state = ConnectionState.DISCONNECTED
	multiplayer.multiplayer_peer = null
	peer = null
	my_id = -1


## Handle successful connection to server (client successfully joined)
func _on_connected_to_server():
	print("Connected to server")
	state = ConnectionState.CONNECTED # Client is now connected
	my_id = multiplayer.get_unique_id()
	connected.emit()


## Handle server disconnection (server went down unexpectedly)
## "I (a client) have lost connection to the server", Host never receives this
func _on_disconnected_from_server():
	print("Server disconnected unexpectedly")
	if state != ConnectionState.DISCONNECTED:
		disconnected.emit()
		state = ConnectionState.DISCONNECTED
		multiplayer.multiplayer_peer = null
		peer = null
		my_id = -1


## Get the ID of the current player
## @return: The ID of the current player
func get_my_id() -> int:
	return my_id


## Check if the current player is the host
## @return: True if the current player is the host, false otherwise
func is_host() -> bool:
	return state == ConnectionState.HOST


## Get the current connection state
## @return: The current connection state as a ConnectionState enum value
func get_connection_state() -> ConnectionState:
	return state


## Get the connected players (excluding itself)
## @return: Array of player IDs currently connected to the server
func get_connected_players() -> PackedInt32Array:
	return multiplayer.get_peers()


# Data transmission, not necessarily for ENet, as RPCs is more intuitive for most use cases --------
# this is for dynamic data transmission, and transition to the WebSocket

## Send data to a specific player by their ID
## @param player_id: The ID of the player to send data to
## @param data: The data to send, as a Dictionary
func send_to(player_id: int, data: Dictionary):
	if state == ConnectionState.DISCONNECTED:
		push_warning("Cannot send data: not connected")
		return
	if player_id == my_id:
		# Sending to self
		data_received.emit(my_id, data)
		return
	# Send to specific peer
	_receive_data.rpc_id(player_id, data)


## Broadcast data to all connected players, including self
## @param data: The data to broadcast, as a Dictionary
func broadcast(data: Dictionary):
	if state == ConnectionState.DISCONNECTED:
		push_warning("Cannot send data: not connected")
		return
	# Send to self
	data_received.emit(my_id, data)
	# Send to all other connected peers
	_receive_data.rpc(data)


## Selective transmission
## Send data to multiple players by their IDs
## @param player_ids: Array of player IDs to send data to
## @param data: The data to send, as a Dictionary
func send_to_multiple(player_ids: Array[int], data: Dictionary):
	if state == ConnectionState.DISCONNECTED:
		push_warning("Cannot send data: not connected")
		return
	for player_id in player_ids:
		send_to(player_id, data)


## Broadcast data to all players except the one with excluded_id
## @param excluded_id: The ID of the player to exclude from the broadcast
## @param data: The data to broadcast, as a Dictionary
func broadcast_except(excluded_id: int, data: Dictionary):
	if state == ConnectionState.DISCONNECTED:
		push_warning("Cannot send data: not connected")
		return
	if my_id != excluded_id:
		data_received.emit(my_id, data)
	for peer_id in multiplayer.get_peers():
		if peer_id != excluded_id:
			_receive_data.rpc_id(peer_id, data)


## Receive data from other players
@rpc("any_peer", "call_remote", "reliable")
func _receive_data(data: Dictionary):
	var sender_id = multiplayer.get_remote_sender_id()
	data_received.emit(sender_id, data)
# --------------------------------------------------------------------------------------------------

# ----------- Player management used by the host ---------------------------------------------------

## Update the public IP address (host only)
## @param new_public_ip: The public IP address to set
func set_public_ip(new_public_ip: String):
	if not is_host():
		push_warning("set_public_ip() should only be called by host")
		return
	public_ip = new_public_ip.strip_edges() # Remove any leading/trailing whitespace
	print("Public IP updated to: " + public_ip)


## Helper function to select local IP
## Host may have multiple local IPs, such as:
##
## "192.168.?.?"  # Home WiFi networks 		-> Good option
## "10.?.?.?"     # VPN connection 			-> Good option
## "172.?.?.?"    # Some corporate networks -> Good option
## "::1"          # IPv6 localhost			-> Not for everyone
## "169.254.?.?"  # Windows auto-assigned	-> Avoid
## "127.0.0.1"    # localhost				-> Fallback
##
## @return: The best local IP address
func _get_best_local_ip() -> String:
	for ip_addr in IP.get_local_addresses(): # get User's current IPv4, IPv6 addresses as an array.
		if ip_addr.begins_with("192.168.") or ip_addr.begins_with("10.") or ip_addr.begins_with("172."):
			return ip_addr
	return "127.0.0.1"  # Fallback


## Get the connection info of the server
## @return: Connection info string
func get_connection_info() -> String:
	if not is_host():
		push_warning("get_connection_info() should only be called by host")
		return ""
	if public_ip != "":
		return "%s:%d" % [public_ip, port]
	else:
		return "%s:%d" % [_get_best_local_ip(), port]


## Get the number of connected players (including host)
## @return: Total number of players connected to the server
func get_player_count() -> int:
	if not is_host():
		push_warning("get_player_count() should only be called by host")
		return -1
	return multiplayer.get_peers().size() + 1


## Kick a player from the game
## @param player_id: The ID of the player to kick
## @return: True if player was successfully kicked, false otherwise
func kick_player(player_id: int) -> bool:
	if not is_host():
		push_warning("kick_player() should only be called by host")
		return false
	return multiplayer.disconnect_peer(player_id) == OK

# --------------------------------------------------------------------------------------------------



# # Optional features, consider once the base functionality is implemented

# # Network statistics (for debugging)
# func get_last_error() -> String:
#     push_error("Must implement get_last_error")
#     return ""

# func get_ping(player_id: int) -> int:
#     push_error("Must implement get_ping")
#     return -1

# func get_network_stats() -> Dictionary:
#     push_error("Must implement get_network_stats")
#     return {}


# # Message priorities
# enum MessagePriority {
#     LOW,
#     NORMAL,
#     HIGH,
#     CRITICAL
# }

# func send_to_priority(player_id: int, data: Dictionary, priority: MessagePriority = MessagePriority.NORMAL):
#     push_error("Must implement send_to_priority")

# # Bandwidth management
# func set_bandwidth_limit(bytes_per_second: int):
#     push_error("Must implement set_bandwidth_limit")

# # Compression toggle
# func set_compression_enabled(enabled: bool):
#     push_error("Must implement set_compression_enabled")

# # Graceful shutdown
# func shutdown():
#     push_error("Must implement shutdown")
