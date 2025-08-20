## Base class for all kitchen appliances that can accept and hold items
## Extends Placeable to provide positioning and collision detection
## All appliances support basic put/take operations through virtual methods
class_name Appliance
extends Placeable

## Type of cooking style this appliance supports
@export var cooking_style: ApplianceFactory.CookingStyle = ApplianceFactory.CookingStyle.NONE
var interactable_component: InteractableComponent


## Setup the appliance
func _ready():
	super._ready()
	_setup_interactable()


## Add interactable component to this class
## InteractableComponent is scene dependent, can not instantiate from script
func _setup_interactable():
	var interactable_scene = preload("res://scenes/Interaction/InteractableComponent.tscn")
	interactable_component = interactable_scene.instantiate()
	add_child(interactable_component)
	interactable_component.interacted.connect(_on_interactable_component_interacted)
	interactable_component.toggle_collision.connect(_on_interactable_component_toggle_collision)


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


## Perform action depend on what player is holding
## @param _item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(_item: Node) -> bool:
	assert(false, "player_has() must be implemented in " + get_class())
	return false


## InteractableComponent Signal Handlers -----------------------------------------------------------

## Connect to singal: Called when interacted with and will make the player pick this item up
## @return void
func _on_interactable_component_interacted() -> void:
	player_has(GlobalScript.player.item_in_hand)


# Potentially use it in future
# func _on_interactable_component_hovered(is_hovered: bool) -> void:
# 	pass
# func _on_interactable_component_action_use(is_action: bool) -> void:
# 	pass


func _on_interactable_component_toggle_collision(turn_on: bool) -> void:
	for child in self.get_children():
		if child is CollisionShape3D:
			child.disabled = !turn_on
	$InteractableComponent/CollisionShape3D.disabled = !turn_on
