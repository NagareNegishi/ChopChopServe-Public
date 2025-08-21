extends Node

enum Team {
	TEAM1,
	TEAM2
}

var player : Player
var playerColours = PackedColorArray([Color("fcdefb",1), Color("cfecf8",1), Color("fccabd",1), Color("f8fab4",1)]) # Colours: Pink, Blue, Red, Yellow
var ui_game_state : UIGameState 


## Called when the node enters the scene tree for the first time.
## @return void
func _ready() -> void:
	if get_tree().get_current_scene().has_node("Player"):
		player = get_tree().get_current_scene().get_node("Player")
		
	if get_tree().get_current_scene().has_node("HUD"):
		ui_game_state = get_tree().get_current_scene().get_node("HUD")
