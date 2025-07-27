# Appliance Plan

Depending on how cooking mechanics are implemented, we may need to adjust the implementation.
However, some requirement I can address now:

- It need to be able to place somewhere in the kitchen -> need to be able to tell its size and position
- Depend on how freely the player can place the appliance, it may need to be moved around or rotated
- It should have state, but details of the state will depend on the cooking mechanics:
    - It should at least have:
        - Is it on or off?
        - Is it currently cooking something?
        - What is the current temperature?
        - What is the current cooking time?
    - It should be able to interact with items in the kitchen?
    - It can be broken or caught on fire?
- It can be upgraded, which should increase its efficiency or capacity:
    - It can cook faster
    - It can cook more items at once
    - It can cook more types of items?
    - Does size change with upgrades?

For the flexibility of the appliance, it should have superclass that defines the basic functionality:

```gdscript

class_name Appliance
extends Node2D

# Physical properties
@export var size: Vector2 = Vector2(64, 64)
@export var can_rotate: bool = true
var appliance_id: int = -1

# Collision detection
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D

func _ready():
    # Setup collision shape to match size
    var shape = RectangleShape2D.new()
    shape.size = size
    collision_shape.shape = shape
    
    # Connect collision signals
    area_2d.area_entered.connect(_on_collision_detected)

func get_bounds() -> Rect2:
    return Rect2(position - size/2, size)

func rotate_appliance(angle: float):
    if can_rotate:
        rotation = angle
        # Might need to swap width/height for rotated appliances
        if abs(fmod(rotation, PI)) > PI/4:  # If rotated ~90 degrees
            size = Vector2(size.y, size.x)  # Swap dimensions

```