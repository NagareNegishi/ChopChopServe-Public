class_name InputUI extends TextureRect

@export var keyboard_texture : Texture
@export var controller_texture : Texture
@export var use_scale : bool = true
@export var use_modulate : bool = true

var size_map = {
	"KEY_BIG" : Vector2(41, 23),
	"KEY_SMALL" : Vector2(35,23),
	"CONT" : Vector2(35,23),
}
func _ready() -> void:
	Input.joy_connection_changed.connect(_update)
	_update(0, Input.get_connected_joypads().size() >= 1)

func _update(device : int, connected : bool):
	texture = keyboard_texture if !connected else controller_texture
	if use_modulate: self_modulate = Color("2f2f2f") if !connected else Color("ffffff")
	visible = texture != null && get_parent().get_parent() is not UIRecipes
	if use_scale: 
		$ColorRect.size = Vector2(35,23) if connected else Vector2(41, 23)
		pivot_offset = size/2
		scale = Vector2(1,1) if !connected else Vector2(0.6,0.6)
