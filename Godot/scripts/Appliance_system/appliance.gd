## Base class for all kitchen appliances that can accept and hold items
## Extends Placeable to provide positioning and collision detection
## All appliances support basic put/take operations through virtual methods
class_name Appliance
extends Placeable

signal food_placed(contents)
signal food_taken
signal add_appliance(cookware)
enum Owner {
	NONE,
	TEAM1,
	TEAM2
}

@export_group("REQUIRED - You must set this!")
@export var using_tscn: bool = false
@export var unique_name: String = "UNNAMED_APPLIANCE"
@export var current_owner: Owner = Owner.TEAM1 #Owner.NONE

@export_group("Appliance Settings")
## Type of cooking style this appliance supports
@export var cooking_style: ApplianceFactory.CookingStyle = ApplianceFactory.CookingStyle.NONE

# Reference to components
var interactable_component: InteractableComponent
var highlight_component: ApplianceHighlight
var power_upgradable: Upgradable
var capacity_upgradable: Upgradable
# var coefficient_upgradable: Upgradable

var contents: Array[Node] = []
var contents_names: Array[String] = []: set = _set_contents_names
static var price: int = 100


## Setup the appliance
func _ready():
	super._ready()
	_setup_interactable()
	_setup_highlight()
	_setup_upgradable()
	if using_tscn:
		_check_unique_name()
		ApplianceManager.register_appliance(self, current_owner, name)


## If instance is made through .tscn, it must have a unique name
func _check_unique_name():
	#assert(unique_name != "UNNAMED_APPLIANCE", "Appliance has not been given a unique name!")
	name = unique_name


## Add synchronization properties for the placeable object
func _add_sync_properties(config: SceneReplicationConfig):
	super._add_sync_properties(config)
	config.add_property(NodePath(".:current_owner"))
	config.add_property(NodePath(".:contents_names"))


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
	# # Create coefficient upgradable
	# coefficient_upgradable = Upgradable.new()
	# coefficient_upgradable.upgradable_property = "coefficient"
	# coefficient_upgradable.upgrade_mode = Upgradable.UpgradeMode.ADD
	# add_child(coefficient_upgradable)


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
			#print("Power upgrade enabled for: ", get_script().get_global_name())
			#-------------------------------------------------------------------
			return true
		"capacity":
			capacity_upgradable.upgrade_values = values
			capacity_upgradable.upgrade_costs = costs
			capacity_upgradable.enabled = true
			#-------------------------------------------------------------------
			#print("Capacity upgrade enabled for: ", get_script().get_global_name())
			#-------------------------------------------------------------------
			return true
		# "coefficient":
		# 	coefficient_upgradable.upgrade_values = values
		# 	coefficient_upgradable.upgrade_costs = costs
		# 	coefficient_upgradable.enabled = true
		# 	#-------------------------------------------------------------------
		# 	#print("Coefficient upgrade enabled for: ", get_script().get_global_name())
		# 	#-------------------------------------------------------------------
		# 	return true
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


## Getter for Price
## @return: The price of the appliance
func get_price() -> int:
	return price


## Getter for Owner
## @return: The owner of the appliance
func get_appliance_owner() -> Owner:
	return current_owner


## Setter for Owner
## @param team_number: The team number to set as the owner
func set_appliance_owner(team_number: int) -> void:
	match team_number:
		1:
			current_owner = Owner.TEAM1
		2:
			current_owner = Owner.TEAM2
		_:
			current_owner = Owner.NONE



## Update contents names and refresh contents array
## @param new_names: The new array of contents names
func _set_contents_names(new_names: Array[String]):
	print("I am : ", get_script().get_global_name(), ", Setting contents names is triggered with: ", new_names, "------ My ID is: ", ENetManager.get_my_id())
	contents_names = new_names
	_update_contents()


## Update contents array based on contents names
func _update_contents():
	print("=================================================================")
	print("before update, contents is: ", contents)
	contents.clear()
	for item_name in contents_names:
		var item = get_node_or_null(NodePath(item_name))
		print("NodePath: ", NodePath(item_name))
		if item:
			print("Found item: ", item.get_script().get_global_name())
			contents.append(item)
		else:
			print("Item '", item_name, "' not found as child of ", name)



## InteractableComponent Signal Handlers -----------------------------------------------------------

## Perform action depend on what player is holding
## @param _item: The Node Player is holding
func player_has(_item: Node) -> void:
	assert(false, "player_has() must be implemented in " + get_class())



## Called when interacted with and will make the player pick this item up
## @return void
func _on_interactable_component_interacted() -> void:
	player_has(GlobalScript.get_local_player().item_in_hand)


## Let toggle collision
## @param turn_on: Whether to enable or disable collision
func _on_interactable_component_toggle_collision(turn_on: bool) -> void:
	collision_shape.disabled = not turn_on
	$InteractableComponent/CollisionShape3D.disabled = not turn_on
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
	var item = GlobalScript.get_local_player().item_in_hand
	#---------------------------------------------------------------------------
	if item:
		print("Player with ID: ", ENetManager.get_my_id(), " has : ", item.get_script().get_global_name(), ", hovered: ", get_script().get_global_name())
	#---------------------------------------------------------------------------
	if not item:
		highlight_component.set_state(ApplianceHighlight.HighlightState.HOVER)
		return
	var can_accept = _can_accept(item)
	highlight_component.show_feedback(can_accept)


## Trigger action, if subclass has action
func _on_interactable_component_action_use(_is_action: bool) -> void:
	if _is_action:
		print("Player used action on: ", get_script().get_global_name(), ", but, it does not have action.")


## TODO: Probably implement this in InteractableComponent not here
## Toggle interaction
func _toggle_interaction(can_interact: bool) -> void:
	interactable_component.can_be_interacted = can_interact
	interactable_component.turn_on_collision(can_interact)
## -------------------------------------------------------------------------------------------------
