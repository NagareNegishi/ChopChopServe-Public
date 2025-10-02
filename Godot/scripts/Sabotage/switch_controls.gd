extends Node3D

################################################################################
# TODO:
	# - Tidy code up
	# - Figure out how to get the player node properly
	# - Add timer for the switch back
	# - Basically everything lol
################################################################################

@onready var player = get_node("Player")

var id
var target_team
var target_player

func switch_controls(teamID: int) -> void:
	var cook = get_tree().get_current_scene().get_node_or_null("Player")

	print("jess: the cook is: ", cook)
	id = cook.get_my_id()
	print("jess: my id is: ", id)
	if ENetManager.get_team(id) == 1:
		target_team = ENetManager.get_team2()
	else:
		target_team = ENetManager.get_team1()
	print("jess: target team is:  ", target_team)

	for p in target_team:
		target_player = p.get_player()
		target_player.invert_controls(true)
		print("jess: im switching your controls", p)
