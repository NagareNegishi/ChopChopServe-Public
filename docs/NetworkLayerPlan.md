# Network Layer Plan

Depending on the project progress, we may want to extend the network capabilities, however, considering the 3 months timeline, we need to prioritize essential features first.

1. **ENet**: Use server-client architecture with local network, one player acts as a server, the other as a client.
2. **Steam or Epic**: Integrate with Steam or Epic for online multiplayer capabilities, allowing players to connect over the internet.
3. **WebRTC**: If we decide to implement a web-based version, we can use WebRTC for peer-to-peer connections, enabling real-time communication between players without a central server.

First focus on implementing **ENet** for local multiplayer, for submission purposes.
However, considering future extensions, we should make the network layer abstract such as:

```gdscript

class_name NetworkLayer
extends Node

# Connection lifecycle
func create_game(max_players: int) -> bool:
    push_error("Must implement create_game")
    return false

func join_game(connection_info: String) -> bool:
    push_error("Must implement join_game")
    return false

func disconnect():
    push_error("Must implement disconnect")

# Data transmission
func send_to(player_id: int, data: Dictionary):
    push_error("Must implement send_to")

func broadcast(data: Dictionary):
    push_error("Must implement broadcast")

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

# Events (emitted by implementations)
signal player_joined(id: int)
signal player_left(id: int)
signal connected()
signal disconnected()
signal data_received(from_id: int, data: Dictionary)

```

Subclass may extend this class to implement specific network protocols:

- class_name ENetNetworkLayer extends NetworkLayer
- class_name SteamNetworkLayer extends NetworkLayer
- class_name EpicNetworkLayer extends NetworkLayer
- class_name WebRTCNetworkLayer extends NetworkLayer