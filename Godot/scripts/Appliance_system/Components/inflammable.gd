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
@export var immunity_cost: Array[int] = [500]


var fire_level: float = 0.0
var fire_timer: Timer
var target: Node
var fire_particles: ParticleController
var smoke_particles: ParticleController
var immune_to_fire: bool = false


## Initialize the component
func _ready():
	target = get_parent()
	assert(target != null, "Inflammable component must have a parent!")
	assert("size" in target, "Target must have a 'size' property for Inflammable component!")
	target.add_to_group("flammable")
	_setup_timer()
	_setup_visual_effects()
	_setup_immunity_upgrade()


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


## Setup fire immunity upgrade on target
func _setup_immunity_upgrade():
	assert(target.has_method("register_upgradable"),
		"Target must have register_upgradable method to add fire immunity upgrade.")
	var immunity_upgradable = Upgradable.new()
	immunity_upgradable.upgradable_property = "immune_to_fire"
	immunity_upgradable.upgrade_mode = Upgradable.UpgradeMode.SET
	immunity_upgradable.upgrade_values = [true]
	immunity_upgradable.upgrade_costs = immunity_cost
	immunity_upgradable.enabled = true
	target.register_upgradable(immunity_upgradable)
	Debug.upgrade_log("Fire immunity upgrade enabled for: " + target.name)


## Set target on fire
## @return: True if fire was successfully started
func ignite() -> bool:
	if immune_to_fire:
		Debug.warning("Ignite called on fire-immune appliance: " + target.name)
		return false
	if fire_level > 0:
		Debug.warning("Ignite called on already burning appliance: " + target.name)
		return false

	fire_level = 1
	_start_fire_effects()
	SoundManager.play_sfx_sabotage(SoundManager.SFX_SABOTAGE.IGNITE)
	fire_timer.start()
	fire_started.emit(target)
	Debug.fire_log("Fire started on " + target.name)
	if target is PoweredAppliance:
		target.stop_cook()
		target.broken()
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
		Debug.warning("Extinguish called on non-burning appliance: " + target.name)
		return false
	fire_level -= reduction
	if fire_level <= 0:
		_stop_fire()
	else:
		Debug.fire_log("Fire reduced on " + target.name + ", fire level: " + str(fire_level))
	return true


## Fully stop the fire
func _stop_fire() -> void:
	fire_level = 0
	fire_timer.stop()
	_stop_fire_effects()
	fire_extinguished.emit(target)
	Debug.fire_log("Fire fully extinguished on " + target.name)
	if target is PoweredAppliance:
		target.repair()
	elif target is Bench:
		target.current_status = target.Status.IDLE


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
			Debug.fire_log("Fire level exceeded maximum on " + target.name)
	Debug.fire_log("Fire increased on " + target.name + ", fire level: " + str(fire_level))
