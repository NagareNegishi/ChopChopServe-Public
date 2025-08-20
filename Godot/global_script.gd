extends Node

var player : Player
var playerColours = PackedColorArray([Color("fcdefb",1), Color("cfecf8",1), Color("fccabd",1), Color("f8fab4",1)]) # Colours: Pink, Blue, Red, Yellow

## Called when the node enters the scene tree for the first time.
## @return void
func _ready() -> void:
	if get_tree().get_current_scene().has_node("Player"):
		player = get_tree().get_current_scene().get_node("Player")
