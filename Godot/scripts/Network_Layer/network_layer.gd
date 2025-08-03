## Network Layer Base Class for Godot
# This class defines the interface for network layer implementations in Godot.
# It should be extended by specific network implementations (e.g., WebSocket, ENet, etc.)
class_name NetworkLayer
extends Node

# Events (emitted by implementations)
signal player_joined(id: int)
signal player_left(id: int)
signal connected()
signal disconnected()
signal data_received(from_id: int, data: Dictionary)

# signal connection_failed(reason: String)
# signal player_connection_lost(id: int, reason: String)
# signal network_error(error: String)

enum ConnectionState {
    DISCONNECTED,
    CONNECTING,
    CONNECTED,
    HOST
}

# Connection lifecycle
func create_game(max_players: int) -> bool:
    push_error("Must implement create_game")
    return false

func join_game(connection_info: String) -> bool:
    push_error("Must implement join_game")
    return false

func leave_game():
    push_error("Must implement leave_game")

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
    push_error("Must implement get_my_id")
    return -1

func is_host() -> bool:
    push_error("Must implement is_host")
    return false

func get_connection_info() -> String:
    push_error("Must implement get_connection_info")
    return ""

# Player management used by the host
func get_connected_players() -> Array[int]:
    push_error("Must implement get_connected_players")
    return []

func get_player_count() -> int:
    push_error("Must implement get_player_count")
    return 0

func kick_player(player_id: int) -> bool:
    push_error("Must implement kick_player")
    return false

# Connection state
func get_connection_state() -> ConnectionState:
    push_error("Must implement get_connection_state")
    return ConnectionState.DISCONNECTED


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