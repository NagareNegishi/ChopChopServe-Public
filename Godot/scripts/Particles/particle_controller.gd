class_name ParticleController
extends Node3D

enum EffectType {
	SIZZLE,
	BUBBLE,
	FIRE,
	SMOKE,
	WATER_SPROUT
}

const PARTICLE_SCENE = {
	EffectType.SIZZLE: preload("res://scenes/Particle_effect/sizzle.tscn"),
	EffectType.BUBBLE: preload("res://scenes/Particle_effect/bubble.tscn"),
	EffectType.FIRE: preload("res://scenes/Particle_effect/fire.tscn"),
	EffectType.SMOKE: preload("res://scenes/Particle_effect/smoke.tscn"),
	EffectType.WATER_SPROUT: preload("res://scenes/Particle_effect/waterSprout.tscn")
}

@export var current_effect: EffectType = EffectType.SIZZLE
var particle_instance: Node3D
var particles: GPUParticles3D


## Use this to instantiate a new ParticleController with a specific effect
##
## Create a new ParticleController with a specific effect
## @param effect The effect type to use for the new controller
## @return A new instance of ParticleController
static func create_with_effect(effect: EffectType) -> ParticleController:
	var controller = ParticleController.new()
	controller.current_effect = effect
	return controller


## Set up particle effects
func _ready():
	particle_instance = PARTICLE_SCENE[current_effect].instantiate()
	add_child(particle_instance)
	particles = particle_instance.get_node("GPUParticles3D")
	assert(particles != null, "GPUParticles3D not found in particle scene!")
	particles.emitting = false


## Turn on particle effects
func play():
	particles.emitting = true


## Turn off particle effects
func stop():
	particles.emitting = false


## Switch particle effect
## @param new_effect The effect type to switch to
func switch_effect(new_effect: EffectType):
	## Dispose current effect
	if particles:
		particles.emitting = false
	if particle_instance:
		particle_instance.queue_free()
	# Create new effect
	current_effect = new_effect
	particle_instance = PARTICLE_SCENE[current_effect].instantiate()
	add_child(particle_instance)
	particles = particle_instance.get_node("GPUParticles3D")


## Scale up particle effects
func set_scale_multiplier(scale_factor: float):
	if particle_instance:
		particle_instance.scale = Vector3.ONE * scale_factor
