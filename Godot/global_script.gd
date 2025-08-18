extends Node

var player : Player
var playerColours = PackedColorArray([Color("f542ef",1), Color("3e67fa",1), Color("f24418",1), Color("ebf218",1)]) # Colours: Pink, Blue, Red, Yellow

## Called when the node enters the scene tree for the first time.
## @return void
func _ready() -> void:
	if get_tree().get_current_scene().has_node("Player"):
		player = get_tree().get_current_scene().get_node("Player")
