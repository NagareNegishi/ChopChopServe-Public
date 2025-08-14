class_name MoveParticles 
extends Node3D

var is_active : bool = false

func set_active(active : bool):
	is_active = active
	$GPUParticles3D.emitting = is_active
	
func _on_gpu_particles_3d_finished() -> void:
	$Timer.start()

func _on_timer_timeout() -> void:
	is_active = false
