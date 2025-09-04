extends Node

const SHOULD_LOAD : bool = false
const IPADDRESS : String = "10.20.216.38"
const PORT : int = 25565

var peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()

## Called when the node enters the scene tree for the first time.
## @return void 
func _ready() -> void:
	if !SHOULD_LOAD:
		return
	
	#Signals to test if players are connecting
	#multiplayer.connected_to_server.connect(_on_connected)
	#multiplayer.connection_failed.connect(_on_connection_failed)
	#multiplayer.server_disconnected.connect(_on_disconnected)

	var error : Error = peer.create_server(PORT,4)

	if error == OK:
		multiplayer.multiplayer_peer = peer
		print("Server Created")
	else:
		var client : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
		var clinet_error : Error = client.create_client(IPADDRESS,PORT)

		if clinet_error == OK:
			multiplayer.multiplayer_peer = client


## Runs when player is connect to server
## @return void 
func _on_connected():
	print("Connected to server")
	


## Runs when player fails to connect to server
## @return void 
func _on_connection_failed():
	print("Failed to connect to server")


## Runs when player fails to connect to server
## @return void 
func _on_disconnected():
	print("Disconnected from server")
