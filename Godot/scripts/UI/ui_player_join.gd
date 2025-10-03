class_name PlayerJoin
extends Control

const max_rand_rotation : float = 0
@onready var team : ColorRect = $ColorRect2/Team


func change_colour(id : int) -> void:
	$BG_Inner.modulate = GlobalScript.player_colours.get(id - 1)
	$ColorRect.modulate = GlobalScript.player_outline_colours.get(id - 1)
	$BG_Outline.modulate = GlobalScript.player_outline_colours.get(id - 1)
	$ColorRect2.modulate = GlobalScript.player_outline_colours.get(id - 1)
	$ColorRect2/Team.modulate = GlobalScript.player_colours.get(id - 1)


func set_from_id(id : int, index : int):
	var team = ENetManager.get_team2()
	$Panel.modulate = Color("fff6ae") if team.has(id) else Color("f6a19e")
	$BG_Inner.modulate = GlobalScript.player_colours.get(index)
	$ColorRect.modulate = GlobalScript.player_outline_colours.get(index)
	$BG_Outline.modulate = GlobalScript.player_outline_colours.get(index)
	$ColorRect2.modulate = GlobalScript.player_outline_colours.get(index)
	$ColorRect2/Team.modulate = GlobalScript.player_colours.get(index)
	if ENetManager.get_my_id() != id:  return
	rpc("_set_player_name", ENetManager.get_player_list().get(index), GlobalScript.player_name)
	


@rpc("any_peer", "call_local")
func _set_player_name(id : int, p_name : String):
	$Label.text = p_name
