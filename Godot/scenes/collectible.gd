class_name Collectible
extends Node3D

signal collected()

var offset_total : float 
var offset_amount : float = 0.1
func _physics_process(delta: float) -> void:
	rotation.y +=  0.5
	$hat.position += offset_amount
	offset_total += offset_amount
