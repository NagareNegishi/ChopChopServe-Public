## Base class for all kitchen appliances that can accept and hold items
## Extends Placeable to provide positioning and collision detection
## All appliances support basic put/take operations through virtual methods
class_name Appliance
extends Placeable

## Type of cooking style this appliance supports
@export var cooking_style: ApplianceFactory.CookingStyle = ApplianceFactory.CookingStyle.NONE
var interactable_component: InteractableComponent
var highlight_component: ApplianceHighlight


## Setup the appliance
func _ready():
	super._ready()
	_setup_interactable()
	_setup_highlight()


func _setup_highlight():
	highlight_component = ApplianceHighlight.new()
	add_child(highlight_component)

## Add interactable component to this class
## InteractableComponent is scene dependent, can not instantiate from script
func _setup_interactable():
	var interactable_scene = preload("res://scenes/Interaction/InteractableComponent.tscn")
	interactable_component = interactable_scene.instantiate()
	add_child(interactable_component)
	interactable_component.interacted.connect(_on_interactable_component_interacted)
	interactable_component.toggle_collision.connect(_on_interactable_component_toggle_collision)
	interactable_component.hovered.connect(_on_interactable_component_hovered)
	interactable_component.action_use.connect(_on_interactable_component_action_use)


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

## Called when interacted with and will make the player pick this item up
## @return void
func _on_interactable_component_interacted() -> void:
	player_has(GlobalScript.player.item_in_hand)


## Let toggle collision
## @param turn_on: Whether to enable or disable collision
func _on_interactable_component_toggle_collision(turn_on: bool) -> void:
	if turn_on:
		collision_layer = 1
		collision_mask = 1
	else:
		collision_layer = 0
		collision_mask = 0



func _on_interactable_component_hovered(is_hovered: bool) -> void:
	if not is_hovered:
		highlight_component.hide_feedback()
		return
	#---------------------------------------------------------------------------
	print("Player has : ", GlobalScript.player.item_in_hand, ", hovered: ", get_script().get_global_name())

	#---------------------------------------------------------------------------
	if GlobalScript.player.item_in_hand:
		var can_accept = _can_accept(GlobalScript.player.item_in_hand)
		highlight_component.show_feedback(can_accept)
		return
	highlight_component.set_state(ApplianceHighlight.HighlightState.HOVER)



func _on_interactable_component_action_use(is_action: bool) -> void:
	pass
## -------------------------------------------------------------------------------------------------
