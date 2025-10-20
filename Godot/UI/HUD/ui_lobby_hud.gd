extends Control

@export var code_label : Label

func _ready() -> void:
	code_label.text = ENetManager.enet_layer.public_ip.replace(":7000","")
	#get_connection_info()
