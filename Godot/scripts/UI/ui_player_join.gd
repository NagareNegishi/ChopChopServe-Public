class_name PlayerJoin
extends Control

const max_rand_rotation : float = 0
static var id : int = 1
const TEST_NAMES := ["MitchyCakez", "StrawberryFrog", "RubbishCanDan", "Meep"]

func _ready() -> void:
	rotation_degrees = -max_rand_rotation + (randf() * max_rand_rotation * 2)
	change_colour(id)
	change_name(TEST_NAMES.get(id - 1))
	id += 1


func change_colour(id : int) -> void:
	$BG_Inner.modulate = GlobalScript.playerColours.get(id - 1)
	$Name_Inner.modulate = GlobalScript.playerColours.get(id - 1)
	
	$BG_Outline.modulate = GlobalScript.playerColours.get(id - 1).darkened(0.3)
	$Name.modulate = GlobalScript.playerColours.get(id - 1).darkened(0.3)
	
func change_name(_name : String) -> void:
	$Label.text = _name
