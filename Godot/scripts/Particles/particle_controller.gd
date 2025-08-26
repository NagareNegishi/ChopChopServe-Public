class_name ParticleController
extends Node3D

enum EffectType {
	SIZZLE,
	BUBBLE,
	FIRE,
	SMOKE
}

const PARTICLE_SCENE = {
	EffectType.SIZZLE: preload("res://scenes/Particle_effect/sizzle.tscn"),
	EffectType.BUBBLE: preload("res://scenes/Particle_effect/bubble.tscn"),
	EffectType.FIRE: preload("res://scenes/Particle_effect/fire.tscn"),
	EffectType.SMOKE: preload("res://scenes/Particle_effect/smoke.tscn")
}

@export var current_effect: EffectType = EffectType.SIZZLE
var particle_instance: Node3D
var particles: GPUParticles3D

func _ready():
	particle_instance = PARTICLE_SCENE[current_effect].instantiate()
	add_child(particle_instance)
	particles = particle_instance.get_node("GPUParticles3D")
	assert(particles != null, "GPUParticles3D not found in particle scene!")
	particles.emitting = false


static func create_with_effect(effect: EffectType) -> ParticleController:
	var controller = ParticleController.new()
	controller.current_effect = effect
	return controller


func play():
	particles.emitting = true

func stop():
	particles.emitting = false

func switch_effect(new_effect: EffectType):
	if particles:
		particles.emitting = false
	if particle_instance:
		particle_instance.queue_free()
	# Create new effect
	current_effect = new_effect
	particle_instance = PARTICLE_SCENE[current_effect].instantiate()
	add_child(particle_instance)
	particles = particle_instance.get_node("GPUParticles3D")


func set_scale_multiplier(scale_factor: float):
	if particle_instance:
		particle_instance.scale = Vector3.ONE * scale_factor
