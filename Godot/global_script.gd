extends Node

enum Team {
	TEAM1,
	TEAM2
}

var player : Player
var player_colours = PackedColorArray([Color("ff94fc",1), Color("57ceff",1), Color("ff734f",1), Color("76ff61",1)]) # Colours: Pink, Blue, Red, Green
var player_outline_colours = PackedColorArray([Color("f20cb5",1), Color("124dff",1), Color("e32f00",1), Color("1cd400",1)]) # Colours: Pink, Blue, Red, Green
var ui_game_state : UIGameState 


## Called when the node enters the scene tree for the first time.
## @return void
func _ready() -> void:
	if get_tree().get_current_scene().has_node("Player"):
		player = get_tree().get_current_scene().get_node("Player")
		print("Found Player")
		
	if get_tree().get_current_scene().has_node("HUD"):
		ui_game_state = get_tree().get_current_scene().get_node("HUD")


func get_random_team() -> GlobalScript.Team:
	return GlobalScript.Team.TEAM1 if (randf() <= 0.5) else GlobalScript.Team.TEAM2
