## Base class for all kitchen appliances that can accept and hold items
## Extends Placeable to provide positioning and collision detection
## All appliances support basic put/take operations through virtual methods
class_name Appliance
extends Placeable

## Type of cooking style this appliance supports
@export var cooking_style: ApplianceFactory.CookingStyle = ApplianceFactory.CookingStyle.NONE

## Setup the appliance
func _ready():
	super._ready()

## Place an item onto this appliance
## @param item: The Node to place on this appliance
## @return: True if placement was successful, false otherwise
func put(_item: Node) -> bool:
	assert(false, "put() must be implemented in " + get_class())
	return false


## Remove and return an item from this appliance
## @return: The Node that was removed, or null if nothing to take
func take() -> Node:
	assert(false, "take() must be implemented in " + get_class())
	return null


## Check if this appliance can accept the given item
## @param item: The Node to test for acceptance
## @return: True if item can be placed, false otherwise
func _can_accept(_item: Node) -> bool:
	assert(false, "can_accept() must be implemented in " + get_class())
	return false