## Generic upgrade component - add as child to make any object upgradable
## It handles upgrade logic, but user is responsible for correct setup
## Configure property name, values, costs in inspector
class_name Upgradable
extends Node

signal upgrade_completed(upgradable_property: String)

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
var enabled: bool = false


## Initialize the component
func _ready():
	target = get_parent()
	if not target:
		assert(false, "Upgradable component must have a parent.")


## Calculate maximum upgrade level
## @return: Maximum level based on upgrade_costs and upgrade_values sizes
func get_max_level() -> int:
	if upgrade_costs.size() != upgrade_values.size():
		Debug.warning("upgrade_costs and upgrade_values have different sizes! Using minimum.")
		return min(upgrade_costs.size(), upgrade_values.size())
	return upgrade_costs.size()


## Check if this component can be upgraded further
## @return: True if current level is less than maximum level
func can_upgrade() -> bool:
	return enabled and current_level < max_level


## Check the cost for the next upgrade level
## @return: Cost for the next upgrade level, or 0 if at max level
func get_upgrade_cost() -> int:
	if can_upgrade():
		return upgrade_costs[current_level]
	return 0


## Get information about this upgradable component
## @return: Dictionary with property name and current level
func get_info() -> Dictionary:
	return {
		"property": upgradable_property,
		"level": current_level
	}


## Send upgrade request to authority from the player
## @param player_id: Which player (1-4) is requesting the upgrade
func request_upgrade(player_id: int) -> void:
	if not enabled:
		Debug.error("Upgrade not enabled for: " + target.name)
		return
	if not can_upgrade():
		Debug.warning(upgradable_property + " already at Max level: " + target.name)
		return
	if ENetManager.is_host():
		_attempt_upgrade(player_id, get_upgrade_cost())
	else:
		_request_upgrade_as_host.rpc_id(1, player_id)


## Host-side method to handle upgrade requests from clients
## @param player_id: The id of the player who is requesting the upgrade
@rpc("any_peer", "call_remote", "reliable")
func _request_upgrade_as_host(player_id: int) -> void:
	if not ENetManager.is_host():
		return
	# Validate again on host side
	if can_upgrade():
		_attempt_upgrade(player_id, get_upgrade_cost())


## Attempt to perform the upgrade, deducting currency, Host only
## @param player_id: The id of the player who is requesting the upgrade
## @param cost: The cost of the upgrade
func _attempt_upgrade(player_id: int, cost: int) -> void:
	if CurrencySystem.can_afford(ENetManager.get_team(player_id), cost):
		CurrencySystem.minus_currency(ENetManager.get_team(player_id), cost)
		_upgrade.rpc()


## Attempts to upgrade to the next level
@rpc("authority", "call_local", "reliable")
func _upgrade() -> void:
	if current_level >= max_level:
		Debug.error("Cannot upgrade " + upgradable_property + " on " + target.name)
		return
	var new_value = upgrade_values[current_level]
	if _handle_special_upgrade(new_value):
		return
	match upgrade_mode:
		UpgradeMode.ADD:
			target.set(upgradable_property, target.get(upgradable_property) + new_value)
		UpgradeMode.MULTIPLY:
			target.set(upgradable_property, target.get(upgradable_property) * new_value)
		UpgradeMode.SET:
			target.set(upgradable_property, new_value)  # Works for ANY type
		_:
			Debug.error("Invalid upgrade_mode: " + str(upgrade_mode) + " for " + upgradable_property)
			return
	current_level += 1
	upgrade_completed.emit(upgradable_property)
	Debug.upgrade_log("Upgraded: " + upgradable_property + " to level " + str(current_level)
		+ " on " + target.name)


## Handle special cases like component properties
## @return: True if handled, false to continue with normal upgrade
func _handle_special_upgrade(new_value) -> bool:
	# Handle inflammable component immunity
	if upgradable_property == "immune_to_fire":
		var inflammable = target.get_node_or_null("Inflammable")
		if inflammable:
			inflammable.immune_to_fire = new_value
			current_level += 1
			upgrade_completed.emit(upgradable_property)
			Debug.upgrade_log(target.name + " is now immune to fire!")
			return true
		Debug.error("Tried to upgrade fire immunity but no Inflammable component found")
		return false
	return false