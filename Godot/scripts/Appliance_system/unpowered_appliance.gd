## Unpowered kitchen appliances that cannot cook food
## Examples: Bench, Sink, Trash Can, Food Crate
class_name UnPoweredAppliance
extends Appliance


enum Status {
	IDLE,
	USING,
	UNABLE
}

@export_group("UnPoweredAppliance Settings")
@export var capacity: int = 4 ## Maximum number of items this appliance can hold
@export var action_interval: float = 1.0 ## action every ? seconds

var current_status: Status = Status.IDLE
var action_timer: Timer

# variable for supplier type
var prefix: String
var supply_count: int


func _ready():
	super._ready()
	# Create and configure timer
	action_timer = Timer.new()
	action_timer.wait_time = action_interval
	action_timer.timeout.connect(_on_action_timer_timeout)
	add_child(action_timer)


## Add synchronization properties for the placeable object
func _add_sync_properties(config: SceneReplicationConfig):
	super._add_sync_properties(config)
	config.add_property(NodePath(".:current_status"))
	config.add_property(NodePath(".:capacity"))


## Set the prefix for the Object supplied by this appliance
func _set_affixes():
	supply_count = 1
	if current_owner == Owner.TEAM1:
		prefix = "T1_"
	elif current_owner == Owner.TEAM2:
		prefix = "T2_"
	else:
		prefix = "T0_"


## Place an item onto this appliance
## @param item: The Node to place on this appliance
## @return: True if placement was successful, false otherwise
func put(item: Node) -> bool:
	if not _can_accept(item):
		return false
	contents.append(item)
	add_child(item)

#-------------------------------------------------------------------------------
	contents_names.append(item.name)
#-------------------------------------------------------------------------------


	return true


## Remove and return the last item from this appliance
## @return: The Node that was removed, or null if nothing to take
func take() -> Node:
	if contents.is_empty():
		return null
	var item = contents.pop_back()


#-------------------------------------------------------------------------------
	if not contents_names.is_empty():
		contents_names.pop_back()
#-------------------------------------------------------------------------------



	remove_child(item)
	return item


## Check if this appliance can accept the given item
## @param item: The Node to test for acceptance
## @return: True if item can be placed, false otherwise
func _can_accept(item: Node) -> bool:
	if not item:
		print("Cannot accept item, item is null")
		return false
	if contents_names.size() >= capacity:
		print("Cannot accept item: ", get_script().get_global_name(), " is at full capacity")
		return false
	if not item.get_script():
		print("Cannot accept item, item has no script")
		return false
	return true # Minimum requirement


## Start action process, and unable further actions until it completes
## Subclasses may wrap this method with intuitive name to implement specific action behavior
## @return: True if action started
func start_action() -> bool:
	if current_status != Status.IDLE:
		return false
	if contents.is_empty():
		push_warning("No items to act on")
		return false
	current_status = Status.USING
	action_timer.start()
	return _action()


## Perform action logic
## This method should be overridden in subclasses to implement specific action behavior
func _action() -> bool:
	assert(false, "action() must be implemented in " + get_class())
	return false


## Timer callback to handle action logic
func _on_action_timer_timeout():
	current_status = Status.IDLE
	action_timer.stop()


## For Player interaction --------------------------------------------------------------------------
## Place an item onto this appliance from Player
## if we could remove Player dependency from this class, we can remove this method
## @param item: The Node to place on this appliance
## @return: True if placement was successful, false otherwise
func put_from_player(item: Node) -> bool:
	if not _can_accept(item):
		return false
	# transfer item to appliance
	GlobalScript.player.remove_item()
	contents.append(item)
	add_child(item)

#-------------------------------------------------------------------------------
	contents_names.append(item.name)
#-------------------------------------------------------------------------------

#--------------------------------------------
	print("Put: ", item.get_script().get_global_name(), " onto: ", get_script().get_global_name())
#--------------------------------------------
	return true
#---------------------------------------------------------------------------------------------------