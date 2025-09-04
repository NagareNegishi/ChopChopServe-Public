class_name PlayerJoin
extends Control

const max_rand_rotation : float = 0
const TEST_NAMES := ["MitchyCakez", "StrawberryFrog", "RubbishCanDan", "Meep"]

static var id : int = 1

func _ready() -> void:
	rotation_degrees = -max_rand_rotation + (randf() * max_rand_rotation * 2)
	change_colour(id)
	id += 1


func change_colour(id : int) -> void:
	$BG_Inner.modulate = GlobalScript.player_colours.get(id - 1)
	$ColorRect.modulate = GlobalScript.player_outline_colours.get(id - 1)
	$BG_Outline.modulate = GlobalScript.player_outline_colours.get(id - 1)
	
