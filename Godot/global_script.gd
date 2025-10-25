extends Node

signal tutorial_step(num : int)

enum UpgradeType{
	POWER,
	COEFF,
	CAP
}

static var tutorial_counter_tomato = 0
var player : Player
var player_colours = PackedColorArray([Color("ff94fc",1), Color("57ceff",1), Color("ff734f",1), Color("76ff61",1)]) # Colours: Pink, Blue, Red, Green
var player_outline_colours = PackedColorArray([Color("ed58d1",1), Color("4f77f0",1), Color("e32f00",1), Color("53ba43",1)]) # Colours: Pink, Blue, Red, Green
var ui_game_state : UIGameState 

var player_name : String


## Called when the node enters the scene tree for the first time.
## @return void
func _ready() -> void:
	if get_tree().get_current_scene().has_node("Player"):
		player = get_tree().get_current_scene().get_node("Player")
		print("Found Player")
		
	if get_tree().get_current_scene().has_node("HUD"):
		ui_game_state = get_tree().get_current_scene().get_node("HUD")


func get_local_player() -> Player:
	var my_id = multiplayer.get_unique_id()
	if !get_tree().current_scene.get_node("== PLAYERS =="):
		return null
	
	for child : Player in get_tree().current_scene.get_node("== PLAYERS ==").get_children():
		if child.get_multiplayer_authority() == my_id:
			return child
	return null


func get_local_player_by_id(player_id : int) -> Player:
	if !get_tree().current_scene.get_node("== PLAYERS =="):
		return null
	
	for child : Player in get_tree().current_scene.get_node("== PLAYERS ==").get_children():
		if child.get_multiplayer_authority() == player_id:
			return child
	return null

func get_all_players():
	return get_tree().current_scene.get_node("== PLAYERS ==").get_children()


func array_check_tomato(contents : Array) -> bool:
	if contents == null or contents.is_empty(): return false
	for f in contents:
		if f == null: return false
		if f is Tomato: continue
		return false 
	return true
