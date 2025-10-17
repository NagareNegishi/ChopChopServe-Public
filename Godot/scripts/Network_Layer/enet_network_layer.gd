class_name ENetNetworkLayer
extends NetworkLayer

signal notify(message: String, duration: float)

enum Reachability { UNKNOWN, PROBABLE, CONFIRMED, FAILED }

@export var port: int = 7000
# @export var bind_ip: String = "0.0.0.0"	## What to bind server to, but no use for Enet
@export var public_ip: String = ""	## What clients should connect to
@export var max_clients: int = 3 ## Maximum players -1, as player 1 is the host

var state: ConnectionState = ConnectionState.DISCONNECTED
var peer: ENetMultiplayerPeer
var my_id: int = -1
var upnp: UPNP = null
var upnp_enabled: bool = false
var upnp_thread = null
var http_request: HTTPRequest
const LOOKUP_SERVER = "https://chopchopserve-production.up.railway.app"
var room_code: String = ""
var reachability: Reachability = Reachability.UNKNOWN


## Setup signals for player management
func _ready():
	# Connect to Godot's built-in multiplayer signals
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_disconnected_from_server)
	_setup_http_request()


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
		Debug.net_log("Already connected or connecting")
		notify.emit("Already connected or connecting", 3.0)
		return false
	if max_players <= 0:
		Debug.net_log("Invalid max players")
		return false
	if max_players > max_clients + 1: # +1 for the host
		Debug.net_log("Max players clamped from %d to %d" % [max_players, max_clients + 1])
		max_players = max_clients + 1
	if host_public_ip != "":
		if not validate_ip(host_public_ip):
			return false

	reachability = Reachability.UNKNOWN
	peer = ENetMultiplayerPeer.new()
	if peer.create_server(port, max_players - 1) == OK:
		multiplayer.multiplayer_peer = peer
		state = ConnectionState.HOST
		my_id = 1 # Host is always ID 1

		# Try UPnP if public IP is not set
		if host_public_ip == "":
			upnp_thread = Thread.new()
			upnp_thread.start(_upnp_setup.bind(port))
		# Use provided public IP if valid format (doesn't mean it's reachable)
		else:
			set_public_ip(host_public_ip)
			room_code = _generate_room_code()
			_register_room_code(room_code, host_public_ip + ":" + str(port))
			Debug.net_log("Using provided public IP: %s, Room code: %s" % [host_public_ip, room_code])

		connected.emit()
		player_joined.emit(my_id)
		Debug.net_log("ENet server created on port %d, max players: %d" % [port, max_players])
		return true
	else:
		Debug.net_log("Failed to create ENet server")
		peer = null
		return false


## Join a server at the specified IP address (and port.)
## @param connection_info: can be "IP:PORT" or just "IP"
## @return: True if connection was successful
func join_game(connection_info: String) -> bool:
	if state != ConnectionState.DISCONNECTED:
		Debug.net_log("Cannot join: already connected or connecting")
		notify.emit("Already connected or connecting", 3.0)
		return false

	# Parse connection_info as "IP:PORT" or "IP"
	var parts: Array = connection_info.split(":")
	var target_ip: String = parts[0] if parts.size() > 0 else "127.0.0.1" # localhost
	if target_ip == "127.0.0.1":
		Debug.net_log("Warning: Using localhost fallback - this won't work for real multiplayer")
	var target_port: int = int(parts[1]) if parts.size() > 1 else port

	peer = ENetMultiplayerPeer.new()
	if peer.create_client(target_ip, target_port) == OK:
		multiplayer.multiplayer_peer = peer
		state = ConnectionState.CONNECTING
		Debug.net_log("Attempting to connect to %s:%d" % [target_ip, target_port])
		notify.emit("Connecting...", 15.0)
		return true
	else:
		Debug.net_log("Failed to create ENet client")
		notify.emit("Failed to start connection", 3.0)
		peer = null
		return false


## Disconnect from the server or stop hosting
func leave_game():
	if peer:
		if state == ConnectionState.HOST:
			Debug.net_log("Host is shutting down the server")
			_cleanup_upnp()
		elif state == ConnectionState.CONNECTED:
			Debug.net_log("Client with network ID: " + str(my_id) + " is going to leave")
		else:
			Debug.net_log("Stop connecting")
		peer.close()
		multiplayer.multiplayer_peer = null
		peer = null
		state = ConnectionState.DISCONNECTED
		my_id = -1
		Debug.net_log(str(my_id) + " left game and disconnected")


## Handle peer connection (when someone joins)
## "A new peer has connected to the same network as me"
func _on_peer_connected(id: int):
	Debug.net_log("Peer connected: %d" % id)
	if state == ConnectionState.HOST:
		if multiplayer.get_peers().size() > max_clients:
			Debug.net_log("Maximum clients reached. Disconnecting new client.")
			multiplayer.disconnect_peer(id)
			return
		player_joined.emit(id)


## Handle peer disconnection (when someone leaves)
## "A peer that was part of our network has left"
func _on_peer_disconnected(id: int):
	Debug.net_log("Peer disconnected: %d" % id)
	if state == ConnectionState.HOST:
		player_left.emit(id)


## Handle connection failure (when join_game fails to connect)
func _on_connection_failed():
	Debug.net_log("Connection to server failed")
	notify.emit("Failed to connect to server.", 3.0)
	state = ConnectionState.DISCONNECTED
	multiplayer.multiplayer_peer = null
	peer = null
	my_id = -1


## Handle successful connection to server (client successfully joined)
func _on_connected_to_server():
	Debug.net_log("Successfully connected to server")
	ENetManager.hide_popup()
	state = ConnectionState.CONNECTED # Client is now connected
	my_id = multiplayer.get_unique_id()
	connected.emit()


## Handle server disconnection (server went down unexpectedly)
## "I (a client) have lost connection to the server", Host never receives this
func _on_disconnected_from_server():
	Debug.net_log("Server disconnected unexpectedly")
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
		Debug.net_log("Cannot send data: not connected")
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
		Debug.net_log("Cannot send data: not connected")
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
		Debug.net_log("Cannot send data: not connected")
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


# Player management used by the host ---------------------------------------------------------------

## Validate an IP address for hosting
## @param ip: The IP address string to validate
## @return: True if valid and usable for public internet, false otherwise
func validate_ip(ip: String) -> bool:
	if not _is_valid_ipv4(ip):
		notify.emit("Invalid IP address format.", 3.0)
		return false
	var usability = check_ip_usability(ip)
	if not usability.usable:
		notify.emit("IP not usable for internet: " + usability.reason, 3.0)
		return false
	return true


## Validate if string is a valid IPv4 address
## @param ip: The IP address string to validate
## @return: True if valid IPv4, false otherwise
func _is_valid_ipv4(ip: String) -> bool:
	ip = ip.strip_edges()
	if ip.is_empty():
		return false
	var parts = ip.split(".")
	if parts.size() != 4:
		return false
	for part in parts:
		if not part.is_valid_int():
			return false
		var num = int(part)
		if num < 0 or num > 255:
			return false
	return true


## Check if a valid IP is usable for public internet hosting
## @param ip: The IP address string to check (must be valid format first)
## @return: Dictionary with {usable: bool, reason: String, is_private: bool}
func check_ip_usability(ip: String) -> Dictionary:
	# Assume IP format is already validated by _is_valid_ipv4()
	var parts = ip.split(".")
	var first = int(parts[0])
	var second = int(parts[1])
	if first == 0: 	# 0.0.0.0/8 - Invalid
		return {"usable": false, "reason": "0.0.0.0/8 is reserved", "is_private": false}
	if first == 127: # 127.0.0.0/8 - Localhost
		return {"usable": false, "reason": "Localhost (not reachable externally)", "is_private": true}
	if first == 10: # 10.0.0.0/8 - Private
		return {"usable": false, "reason": "Private IP (LAN only)", "is_private": true}
	if first == 172 and second >= 16 and second <= 31: # 172.16.0.0/12 - Private
		return {"usable": false, "reason": "Private IP (LAN only)", "is_private": true}
	if first == 192 and second == 168: # 192.168.0.0/16 - Private
		return {"usable": false, "reason": "Private IP (LAN only)", "is_private": true}
	if first == 169 and second == 254: # 169.254.0.0/16 - Link-local
		return {"usable": false, "reason": "Link-local (auto-assigned)", "is_private": false}
	if first >= 224 and first <= 239: # 224.0.0.0/4 - Multicast
		return {"usable": false, "reason": "Multicast address", "is_private": false}
	if first >= 240: # 240.0.0.0/4 - Reserved
		return {"usable": false, "reason": "Reserved range", "is_private": false}
	# Public IP - usable!
	return {"usable": true, "reason": "", "is_private": false}


## Update the public IP address (host only)
## @param new_public_ip: The public IP address to set
func set_public_ip(new_public_ip: String):
	Debug.net_log("Setting public IP to: " + new_public_ip)
	if not is_host():
		push_warning("set_public_ip() should only be called by host")
		return
	public_ip = new_public_ip.strip_edges() # Remove any leading/trailing whitespace
	Debug.net_log("Public IP updated to: " + public_ip)


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


# UPNP support -------------------------------------------------------------------------------------

## Optional UPnP support to automatically open router ports for hosting
## @param server_port: The port number to map on the router
## @return: True if UPnP was successful, false otherwise
func _upnp_setup(server_port: int) -> void:
	# UPNP queries take some time.
	upnp = UPNP.new()
	var discover_result = upnp.discover()
	if discover_result != UPNP.UPNP_RESULT_SUCCESS:
		call_deferred("_upnp_failed", "Discovery failed", discover_result)
		return

	# Check gateway
	if not upnp.get_gateway() or not upnp.get_gateway().is_valid_gateway():
		call_deferred("_upnp_failed", "No valid gateway")
		return

	# Map port
	var map_result = upnp.add_port_mapping(
		server_port,		# External port
		0,			# Internal port (same)
		"Chop Chop Serve",	# Description
		"UDP",		# Protocol
		0			# Permanent until cleanup
	)
	if map_result != UPNP.UPNP_RESULT_SUCCESS:
		call_deferred("_upnp_failed", "UPnP port mapping failed", map_result)
		return

	# Success
	var external_ip = upnp.query_external_address()
	call_deferred("_upnp_succeed", external_ip, server_port)


## UPnP succeeded
## @param external_ip: The external IP address assigned by the router
## @param server_port: The port number that was mapped
func _upnp_succeed(external_ip: String, server_port: int):
	upnp_enabled = true
	set_public_ip(external_ip)
	# Generate and register room code
	room_code = _generate_room_code()
	_register_room_code(room_code, public_ip + ":" + str(server_port))
	reachability = Reachability.PROBABLE
	Debug.net_log("UPnP enabled: %s:%d, Room code: %s" % [external_ip, server_port, room_code])


## UPnP failed
## @param reason: The reason for failure
## @param error_code: Optional error code from UPNP
func _upnp_failed(reason: String, error_code: int = -1):
	upnp = null
	if error_code >= 0:
		Debug.net_log("UPnP failed - %s (code: %d)" % [reason, error_code])
	else:
		Debug.net_log("UPnP failed - %s" % reason)


## Cleanup UPnP mapping, called on exit or when host stops the server
func _cleanup_upnp():
	if upnp_thread and upnp_thread.is_alive():
		upnp_thread.wait_to_finish()
	# Clean up UPnP
	if upnp_enabled and upnp:
		upnp.delete_port_mapping(port, "UDP")
		Debug.net_log("UPnP port mapping removed")
	upnp_enabled = false
	upnp = null


## Cleanup on exit
func _exit_tree():
	_cleanup_upnp()
	# Close peer
	if peer:
		peer.close()


# HTTP request for room lookup services ----------------------------------------

## Setup HTTPRequest node for room lookup services
func _setup_http_request():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_http_request_completed)


## Register room code with lookup server
## @param code: The room code to register
## @param ip: The public IP address of the host
func _register_room_code(code: String, ip: String):
	var body = JSON.stringify(
		{
		"room_code": code,
		"ip": ip
		}
	)
	var error = http_request.request(
		LOOKUP_SERVER + "/register",
		["Content-Type: application/json"],
		HTTPClient.METHOD_POST,
		body
	)
	if error != OK:
		Debug.net_log("An error occurred in the HTTP request.")


## Lookup room code from lookup server
## @param code: The room code to look up
func lookup_room_code(code: String):
	var error = http_request.request(LOOKUP_SERVER + "/lookup/" + code)
	if error != OK:
		Debug.net_log("An error occurred in the HTTP request.")


## Handle HTTP request completion
## @param result: The result of the HTTP request
## @param response_code: The HTTP response code
## @param headers: The response headers
## @param body: The response body
func _on_http_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	# Check for errors
	if result != HTTPRequest.RESULT_SUCCESS:
		Debug.net_log("HTTP request failed with result: %d" % result)
		notify.emit("Failed to contact room server.", 3.0)
		return
	if response_code != 200:
		Debug.net_log("HTTP request returned non-200 status code: %d" % response_code)
		notify.emit("Invalid Room Code.", 3.0)
		return

	# Parse JSON response
	var response = JSON.parse_string(body.get_string_from_utf8())
	if response == null:
		Debug.net_log("Failed to parse JSON response")
		notify.emit("Invalid response from room server.", 3.0)
		return

	# response is a Dictionary at this point
	if response.has("error"):
		Debug.net_log("Server error: %s" % response["error"])
		notify.emit("Invalid request.", 3.0)
		return
	if response.has("success"):
		Debug.net_log("Room registered successfully")
		return
	if response.has("ip"):
		Debug.net_log("Room code lookup successful: " + response["ip"])
		join_game(response["ip"])
		return


## Generate a random 6-character room code
## @return: A random room code string
func _generate_room_code() -> String:
	var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var code = ""
	for i in range(6):
		code += chars[randi() % chars.length()]
	return code


# # Optional features, consider once the base functionality is implemented -------------------------

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
