## Base class for all kitchen appliances that can accept and hold items
## Extends Placeable to provide positioning and collision detection
## All appliances support basic put/take operations through virtual methods
class_name Appliance
extends Placeable

## Type of cooking style this appliance supports
@export var cooking_style: ApplianceFactory.CookingStyle = ApplianceFactory.CookingStyle.NONE
var interactable_component: InteractableComponent
var highlight_component: ApplianceHighlight
var power_upgradable: Upgradable
var capacity_upgradable: Upgradable
var coefficient_upgradable: Upgradable

var price: int = 100


## Setup the appliance
func _ready():
	super._ready()
	_setup_interactable()
	_setup_highlight()
	_setup_upgradable()


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


## Setup the highlight component
func _setup_highlight():
	highlight_component = ApplianceHighlight.new()
	add_child(highlight_component)


## Setup the upgradable components
func _setup_upgradable():
	# Create power upgradable
	power_upgradable = Upgradable.new()
	power_upgradable.upgradable_property = "power"
	power_upgradable.upgrade_mode = Upgradable.UpgradeMode.ADD
	add_child(power_upgradable)
	# Create capacity upgradable
	capacity_upgradable = Upgradable.new()
	capacity_upgradable.upgradable_property = "capacity"
	capacity_upgradable.upgrade_mode = Upgradable.UpgradeMode.ADD
	add_child(capacity_upgradable)
	# Create coefficient upgradable
	coefficient_upgradable = Upgradable.new()
	coefficient_upgradable.upgradable_property = "coefficient"
	coefficient_upgradable.upgrade_mode = Upgradable.UpgradeMode.ADD
	add_child(coefficient_upgradable)


## Enable specific upgrade type
## @param type: The type of upgrade to enable (e.g. "power", "capacity", "coefficient")
## @param values: The array of values for the upgrade
## @param costs: The array of costs for the upgrade
## @return: True if the upgrade was enabled successfully, false otherwise
func enable_upgrade(type: String, values: Array, costs: Array[int]) -> bool:
	if values.size() != costs.size():
		assert(false, "Values and costs arrays must have the same size.")
		return false
	match type:
		"power":
			power_upgradable.upgrade_values = values
			power_upgradable.upgrade_costs = costs
			power_upgradable.enabled = true
			#-------------------------------------------------------------------
			print("Power upgrade enabled for: ", get_script().get_global_name())
			#-------------------------------------------------------------------
			return true
		"capacity":
			capacity_upgradable.upgrade_values = values
			capacity_upgradable.upgrade_costs = costs
			capacity_upgradable.enabled = true
			#-------------------------------------------------------------------
			print("Capacity upgrade enabled for: ", get_script().get_global_name())
			#-------------------------------------------------------------------
			return true
		"coefficient":
			coefficient_upgradable.upgrade_values = values
			coefficient_upgradable.upgrade_costs = costs
			coefficient_upgradable.enabled = true
			#-------------------------------------------------------------------
			print("Coefficient upgrade enabled for: ", get_script().get_global_name())
			#-------------------------------------------------------------------
			return true
		_:
			assert(false, "Unknown upgrade type: " + type)
			return false


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


## Getter for Price
## @return: The price of the appliance
func get_price() -> int:
	return price


## InteractableComponent Signal Handlers -----------------------------------------------------------

## Called when interacted with and will make the player pick this item up
## @return void
func _on_interactable_component_interacted() -> void:
	player_has(GlobalScript.player.item_in_hand)


## Let toggle collision
## @param turn_on: Whether to enable or disable collision
func _on_interactable_component_toggle_collision(turn_on: bool) -> void:
	print("Toggling collision of ", get_script().get_global_name(), " from: ", collision_shape.disabled)
	collision_shape.disabled = not turn_on
	print("Collision of ", get_script().get_global_name(), " toggled to: ", collision_shape.disabled)
	$InteractableComponent/CollisionShape3D.disabled = not turn_on
	print("Collision shape disabled: ", $InteractableComponent/CollisionShape3D.disabled)

	# TODO: When team starts using collision layers properly:
	#
	# if turn_on:
	# 	collision_layer = APPLIANCES
	# 	collision_mask = collide_with
	# else:
	# 	collision_layer = 0
	# 	collision_mask = 0


## Give visual feedback when hovered
## @param is_hovered: Whether the item is hovered or not
func _on_interactable_component_hovered(is_hovered: bool) -> void:
	if not is_hovered:
		highlight_component.hide_feedback()
		return
	#---------------------------------------------------------------------------
	var item = GlobalScript.player.item_in_hand
	if item:
		item = item.get_script().get_global_name()
	print("Player has : ", item, ", hovered: ", get_script().get_global_name())
	#---------------------------------------------------------------------------
	if GlobalScript.player.item_in_hand:
		var can_accept = _can_accept(GlobalScript.player.item_in_hand)
		highlight_component.show_feedback(can_accept)
		return
	highlight_component.set_state(ApplianceHighlight.HighlightState.HOVER)


## Trigger action, if subclass has action
func _on_interactable_component_action_use(_is_action: bool) -> void:
	print("Player used action on: ", get_script().get_global_name(), ", but, it does not have action.")
## -------------------------------------------------------------------------------------------------
