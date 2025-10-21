extends Control

@export var code_label : Label

func _ready() -> void:
	code_label.text = ENetManager.enet_layer.get_connection_info().replace(":7000","")
