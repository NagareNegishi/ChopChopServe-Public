class_name InputUI extends TextureRect

@export var keyboard_texture : Texture
@export var controller_texture : Texture

func _ready() -> void:
	Input.joy_connection_changed.connect(_update)
	_update(0, Input.get_connected_joypads().size() >= 1)

func _update(devine : int, connected : bool):
	texture = keyboard_texture if !connected else controller_texture
