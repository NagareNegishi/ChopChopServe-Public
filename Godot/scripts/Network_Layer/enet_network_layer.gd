class_name ENetNetworkLayer
extends NetworkLayer

# those are in superclass NetworkLayer

# # Events (emitted by implementations)
# signal player_joined(id: int)
# signal player_left(id: int)
# signal connected()
# signal disconnected()
# signal data_received(from_id: int, data: Dictionary)

# # signal connection_failed(reason: String)
# # signal player_connection_lost(id: int, reason: String)
# # signal network_error(error: String)

# enum ConnectionState {
#     DISCONNECTED,
#     CONNECTING,
#     CONNECTED,
#     HOST
# }

@export var port: int = 7000
@export var ip: String = "127.0.0.1" # Default to localhost
@export var max_clients: int = 3 ## Maximum players -1, as player 1 is the host

var state: ConnectionState = ConnectionState.DISCONNECTED
var peer: ENetMultiplayerPeer
var my_id: int = -1


func _ready():
    # Connect to Godot's built-in multiplayer signals
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)
    multiplayer.connection_failed.connect(_on_connection_failed)
    multiplayer.connected_to_server.connect(_on_connected_to_server)
    multiplayer.server_disconnected.connect(_on_server_disconnected)


## Create a server, which is also player 1.
## @param max_players: Maximum number of players including host
## @return: True if server was created successfully
func create_game(max_players: int) -> bool:
    if state != ConnectionState.DISCONNECTED:
        push_warning("Already connected or connecting")
        return false
    if max_players <= 0:
        push_warning("Invalid max players")
        return false
    if max_players > max_clients + 1: # +1 for the host
        print("Max players clamped from %d to %d" % [max_players, max_clients + 1])
        max_players = max_clients + 1

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
    var target_ip: String = parts[0] if parts.size() > 0 else ip # localhost
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
            player_left.emit(my_id)
            print("Server shutdown")
        elif state == ConnectionState.CONNECTED:
            disconnected.emit()
            print("Client with network ID %d disconnected" % my_id)
        else:
            print("Stop connecting")
        
        peer.close()
        multiplayer.multiplayer_peer = null
        peer = null
        state = ConnectionState.DISCONNECTED
        my_id = -1
        print("Left game and disconnected")


# Handle peer connection (when someone joins)
func _on_peer_connected(id: int):
    print("Peer connected: %d" % id)
    if state == ConnectionState.HOST:
        if multiplayer.get_peers().size() > max_clients:
            print("Maximum number of clients reached. Disconnecting new client.")
            multiplayer.disconnect_peer(id)
            return
        player_joined.emit(id)


# Handle peer disconnection (when someone leaves)
func _on_peer_disconnected(id: int):
    print("Peer disconnected: %d" % id)
    if state == ConnectionState.HOST:
        player_left.emit(id)


# Handle connection failure (when join_game fails to connect)
func _on_connection_failed():
    print("Connection failed")
    state = ConnectionState.DISCONNECTED
    multiplayer.multiplayer_peer = null
    peer = null
    my_id = -1


# Handle successful connection to server (client successfully joined)
func _on_connected_to_server():
    print("Connected to server")
    state = ConnectionState.CONNECTED # Client is now connected
    my_id = multiplayer.get_unique_id()
    connected.emit()


# Handle server disconnection (server went down unexpectedly)
func _on_server_disconnected():
    print("Server disconnected unexpectedly")
    if state != ConnectionState.DISCONNECTED:
        disconnected.emit()
        state = ConnectionState.DISCONNECTED
        multiplayer.multiplayer_peer = null
        peer = null
        my_id = -1


# Data transmission
func send_to(player_id: int, data: Dictionary):
    push_error("Must implement send_to")

func broadcast(data: Dictionary):
    push_error("Must implement broadcast")

# Selective transmission (very useful for games)
func send_to_multiple(player_ids: Array[int], data: Dictionary):
    push_error("Must implement send_to_multiple")

func broadcast_except(excluded_id: int, data: Dictionary):
    push_error("Must implement broadcast_except")


# Player info
func get_my_id() -> int:
    return my_id

func is_host() -> bool:
    return state == ConnectionState.HOST

## ---------- Player management used by the host ------------

## Get the connection info of the server
## @return: Connection info string
func get_connection_info() -> String:
    if not is_host():
        push_warning("get_connection_info() should only be called by host")
        return ""
    return "%s:%d" % [ip, port]


## Get the connected players (excluding itself)
## @return: Array of player IDs currently connected to the server
func get_connected_players() -> Array[int]:
    if not is_host():
        push_warning("get_connected_players() should only be called by host")
        return []
    return multiplayer.get_peers()


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

## ---------- Player management used by the host ------------

## Get the current connection state
func get_connection_state() -> ConnectionState:
    return state

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