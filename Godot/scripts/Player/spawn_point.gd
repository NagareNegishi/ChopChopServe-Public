class_name SpawnPoint 
extends Marker3D

@export var currently_active = true
@export var team : GlobalScript.Team
@export var priority : Priority

enum Priority{
	NONE,
	FIRST,
	SECOND
}


func use():
	currently_active = false


func is_active() -> bool:
	return currently_active
