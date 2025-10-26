extends Node3D

@onready var anim_rat: AnimationPlayer = $AnimationPlayer

func _ready(): if anim_rat.has_animation("ArmatureAction"):
	anim_rat.play("ArmatureAction")