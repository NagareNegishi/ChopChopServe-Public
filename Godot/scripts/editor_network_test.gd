extends Node

const SHOULD_LOAD : bool = false
const IPADDRESS : String = "10.20.217.105"
const PORT : int = 25565

var peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()

func _ready() -> void:
	if !SHOULD_LOAD:
		return

	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_disconnected)

	var error : Error = peer.create_server(PORT,4)

	if error == OK:
		multiplayer.multiplayer_peer = peer
		print("Server Created")
	else:
		var client : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
		var clinet_error : Error = client.create_client(IPADDRESS,PORT)

		if clinet_error == OK:
			multiplayer.multiplayer_peer = client

func _on_connected():
	print("Connected to server")

func _on_connection_failed():
	print("Failed to connect to server")

func _on_disconnected():
	print("Disconnected from server")
