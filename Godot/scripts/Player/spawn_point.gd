class_name SpawnPoint 
extends Marker3D

@export var currently_active = true
@export var team : TeamType
@export var priority : Priority

@onready var flag : Sprite3D = $Sprite3D

enum Priority{
	FIRST,
	SECOND
}

enum TeamType{
	ONE = 1,
	TWO = 2
}

func _ready() -> void:
	flag.visible = false
	if team != 1 && team != 2:
		push_error("Invalid Team Num", team)


func use():
	currently_active = false


func is_active() -> bool:
	return currently_active
