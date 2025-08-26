## Inflammable component - add as child to make the parent inflammable
## Manages fire level, visual effects, and appliance state changes
## Target use Inflammable must have a 'size' property (Vector3)
## and must implement following:
## var inflammable_component: Inflammable
##
## func _setup_inflammable():
##     inflammable_component = Inflammable.new()
##     add_child(inflammable_component)
class_name Inflammable
extends Node3D

# signal for server (not target node)
signal fire_started(target: Node)
signal fire_extinguished(target: Node)

@export_group("Fire Configuration")
@export var fire_interval: float = 1.0
## How often to check fire level and update effects (in seconds)
@export var fire_spread_rate: float = 1.0
## How fast fire level increases per second when spreading
@export var max_fire_level: float = 100.0
## Maximum fire intensity level
@export var threshold: float = 80.0 #?????? when to start? stop? spread?


var fire_level: float = 0.0
var fire_timer: Timer
var target: Node
var fire_particles: ParticleController
var smoke_particles: ParticleController


## Initialize the component
func _ready():
	target = get_parent()
	assert(target != null, "Inflammable component must have a parent!")
	assert("size" in target, "Target must have a 'size' property for Inflammable component!")
	target.add_to_group("flammable")
	_setup_timer()
	_setup_visual_effects()
	#----------------------------------------
	#print("Inflammable component added to: ", target.get_script().get_global_name())
	#----------------------------------------


## Setup fire timer
func _setup_timer():
	fire_timer = Timer.new()
	fire_timer.wait_time = fire_interval
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	add_child(fire_timer)


## Setup visual effects
func _setup_visual_effects():
	var target_size = target.size
	fire_particles = ParticleController.create_with_effect(ParticleController.EffectType.FIRE)
	fire_particles.position.y = target_size.y * 0.8
	add_child(fire_particles)
	fire_particles.set_scale_multiplier(8.0)
	
	smoke_particles = ParticleController.create_with_effect(ParticleController.EffectType.SMOKE)
	smoke_particles.position.y = target_size.y * 0.8
	add_child(smoke_particles)
	smoke_particles.set_scale_multiplier(2.0)


## Set target on fire
## @return: True if fire was successfully started
func ignite() -> bool:
	if fire_level > 0:
		push_warning("Ignite called on already burning appliance: " + target.name)
		return false

	fire_level = 1
	_start_fire_effects()
	fire_timer.start()
	fire_started.emit(target)

	if target is PoweredAppliance:
		target.stop_cook()
		target.broken()
		#----------------------------------------
		print("Fire started on ", target.get_script().get_global_name())
		#----------------------------------------
		return true
	elif target is Bench:
		target.on_fire()
		return true
	else:
		assert(false, "Target must be a PoweredAppliance or Bench to ignite.")
		return false


## Reduce fire level by a reduction amount
## @param reduction: Amount to reduce fire level by
## @return: True if fire was successfully reduced,
func extinguish(reduction: int) -> bool:
	if fire_level <= 0:
		push_warning("Extinguish called on non-burning appliance: " + target.name)
		return false

	fire_level -= reduction
	if fire_level <= 0:
		fire_level = 0
		fire_timer.stop()
		_stop_fire_effects()
		fire_extinguished.emit(target)
	#----------------------------------------
	elif target is Bench:
		target.current_status = target.Status.IDLE
	print("Fire extinguished on ", target.get_script().get_global_name(), "fire level: ", fire_level)
	#----------------------------------------
	return true


## Start fire effects
func _start_fire_effects():
	fire_particles.play()
	smoke_particles.play()


## Stop fire effects
func _stop_fire_effects():
	fire_particles.stop()
	smoke_particles.stop()


## Increase fire level
func _on_fire_timer_timeout():
	if fire_level > 0:
		fire_level += fire_spread_rate
		if fire_level >= max_fire_level:
			print("Fire level exceeded maximum") # and what do we want to do with it????
	#----------------------------------------
	print("Fire increased on ", target.get_script().get_global_name(), "fire level: ", fire_level)
	#----------------------------------------


# Note: Initially expected collision layer approach,------------------------------------------------
# however current implementation is using collision of parent.
# the function is unused, but keep it for future use.
#
# var fire_collision_area: Area3D
# var fire_collision_shape: CollisionShape3D
#
## Setup fire collision
# func _setup_fire_collision():
# 	fire_collision_area = Area3D.new()
# 	fire_collision_shape = CollisionShape3D.new()
# 	fire_collision_area.collision_layer = 1
# 	fire_collision_area.collision_mask = 1
# 	fire_collision_area.area_entered.connect(_on_fire_area_entered)
# 	var shape = BoxShape3D.new()
# 	shape.size = target.size # if target is extending Placeable, it should have size property
# 	fire_collision_shape.shape = shape
# 	fire_collision_area.add_child(fire_collision_shape)
# 	add_child(fire_collision_area)
#
# func _on_fire_area_entered(area: Area3D):
# 	pass
#---------------------------------------------------------------------------------------------------





# it should reach here------------------------------------------------------------------------------
#
# func _extingush() -> void:
# 	var collider = $ExtinguishRange.get_collider()
# 	if collider and collider.is_in_group("flammable"):
# 		# Belt and suspenders approach
# 		if "inflammable_component" in collider:
# 			collider.inflammable_component.extinguish(10)
# 		else:
# 			push_error("Flammable object missing inflammable_component!")

# or

# func _extingush() -> void:
# 	var collider = $ExtinguishRange.get_collider()
# 	if collider and collider.is_in_group("flammable"):
# 		collider.inflammable_component.extinguish(10)
