## Generic upgrade component - add as child to make any object upgradable
## It handles upgrade logic, but user is responsible for correct setup
## Configure property name, values, costs in inspector
class_name Upgradable
extends Node

signal upgrade_requested(player_id: int, upgrade_cost: int) # from player
signal upgrade_completed(upgradable_property: String) # from server

enum UpgradeMode {
	ADD,        # For numbers: current + value
	MULTIPLY,   # For numbers: current * value
	SET         # For anything: just set the value
}

@export_group("Upgrade Configuration")
@export var upgrade_mode: UpgradeMode = UpgradeMode.ADD
## How to apply the upgrade value:
## • ADD: Adds upgrade_value to current value (for numbers only)
## • MULTIPLY: Multiplies current value by upgrade_value (for numbers only)
## • SET: Replaces current value with upgrade_value (works for any type)
@export var upgradable_property: String = "power"
## The property name to upgrade on the parent node.
## Must match an existing property on the parent.
@export var upgrade_values: Array = []
## Values for each upgrade level.
## Can contain numbers, strings, textures, booleans, or any other type.
## Must have same number of elements as maximum upgrade levels.
@export var upgrade_costs: Array[int] = []
## Cost required for each upgrade level.
## Must have same number of elements as maximum upgrade levels.

var current_level: int = 0
var max_level: int : get = get_max_level
var target: Node


## Initialize the component
func _ready():
	target = get_parent()
	if not target:
		assert(false, "Upgradable component must have a parent.")
	print("Upgradable component initialized for: ", target.get_script().get_global_name())


## Calculate maximum upgrade level
## @return: Maximum level based on upgrade_costs and upgrade_values sizes
func get_max_level() -> int:
	if upgrade_costs.size() != upgrade_values.size():
		push_warning("upgrade_costs and upgrade_values have different sizes! Using minimum.")
		return min(upgrade_costs.size(), upgrade_values.size())
	return upgrade_costs.size()


## Check if this component can be upgraded further
## @return: True if current level is less than maximum level
func can_upgrade() -> bool:
	return current_level < max_level


## Check the cost for the next upgrade level
## @return: Cost for the next upgrade level, or 0 if at max level
func get_upgrade_cost() -> int:
	if can_upgrade():
		return upgrade_costs[current_level]
	return 0


## Send upgrade request to authority from the player
## @param player_id: Which player (1-4) is requesting the upgrade
func request_upgrade(player_id: int) -> void:
	if not can_upgrade():
		#-----------------------------------------------------------------
		push_warning("Player ", str(player_id), " tried to upgrade ", target.get_script().get_global_name(), " at max level")
		#-----------------------------------------------------------------
		return
	var cost = get_upgrade_cost()
	upgrade_requested.emit(player_id, cost)


## Attempts to upgrade to the next level
## @return: True if upgrade was successful
func upgrade() -> bool:
	if not can_upgrade():
		return false
	var new_value = upgrade_values[current_level]
	match upgrade_mode:
		UpgradeMode.ADD:
			target.set(upgradable_property, target.get(upgradable_property) + new_value)
		UpgradeMode.MULTIPLY:
			target.set(upgradable_property, target.get(upgradable_property) * new_value)
		UpgradeMode.SET:
			target.set(upgradable_property, new_value)  # Works for ANY type
	upgrade_completed.emit(upgradable_property)
	current_level += 1
	return true