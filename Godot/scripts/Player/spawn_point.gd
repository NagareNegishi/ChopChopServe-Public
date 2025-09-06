class_name SpawnPoint 
extends Marker3D

@export var currently_active = true
@export var team : GlobalScript.Team
@export var priority : Priority

@onready var flag : Sprite3D = $Sprite3D

enum Priority{
	NONE,
	FIRST,
	SECOND
}


func _ready() -> void:
	flag.visible = false


func use():
	currently_active = false


func is_active() -> bool:
	return currently_active
