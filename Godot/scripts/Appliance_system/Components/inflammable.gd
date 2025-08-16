## Inflammable component - add as child to make any appliance inflammable
## Manages fire level, visual effects, and appliance state changes
## If you want the target to be broken when on fire, you need to implement func broken() in the target
class_name Inflammable
extends Node3D

signal fire_started(target: Node)
signal fire_extinguished(target: Node)


## may remove or adjust those parameters later!!!!!!!!!!!!!!!!!!
@export_group("Fire Configuration")
@export var fire_interval: float = 1.0
## How often to check fire level and update effects (in seconds)
@export var fire_spread_rate: float = 1.0
## How fast fire level increases per second when spreading

@export var max_fire_level: int = 100
## Maximum fire intensity level
@export var threshold: int = 80 #?????? when to start? stop? spread?

# Assuming particle effects come as PackedScenes!!!!!!!!!!!!!!!!!!!
@export_group("Visual Effects")
@export var fire_scene: PackedScene
## Scene containing fire particle effects
@export var smoke_scene: PackedScene
## Scene containing smoke particle effects

var fire_level: int = 0
var fire_timer: Timer
var target: Node
var fire_particles: Node3D
var smoke_particles: Node3D
var fire_collision_area: Area3D
var fire_collision_shape: CollisionShape3D

func _ready():
    target = get_parent()
    if not target:
        assert(false, "Inflammable component must have a parent appliance!")
        return

    fire_timer = Timer.new()
    fire_timer.wait_time = fire_interval
    fire_timer.timeout.connect(_on_fire_timer_timeout)
    add_child(fire_timer)

    _setup_fire_collision()

    # Initialize visual effects
    _setup_visual_effects()


func _setup_fire_collision():
    fire_collision_area = Area3D.new()
    fire_collision_shape = CollisionShape3D.new()
    fire_collision_area.collision_layer = 0 # we need to define this in some global file!!!!!!!!!!!!!!!!!!!!!!!
    fire_collision_area.area_entered.connect(_on_fire_area_entered)

    var shape = BoxShape3D.new()
    shape.size = target.size # if target is extending Placeable, it should have size property
    fire_collision_shape.shape = shape
    fire_collision_area.add_child(fire_collision_shape)
    add_child(fire_collision_area)



func _on_fire_area_entered(area: Area3D):
    pass

func _setup_visual_effects():
    pass

func _start_fire_effects():
    pass

func _stop_fire_effects():
    pass


func _on_fire_timer_timeout():
    if fire_level > 0:
        fire_level += fire_spread_rate
        if fire_level >= max_fire_level:
            print("Fire level exceeded maximum") # and what do we want to do with it????



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

    if target.has_method("broken"):
        target.broken()
    else:
        push_warning("Target " + target.name + " does not have broken() method")
    return true


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
    return true

