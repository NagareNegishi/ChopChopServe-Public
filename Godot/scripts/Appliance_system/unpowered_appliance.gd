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
	_put(item)
	return true


## Place an item onto this appliance
## @param item: The Node to place on this appliance
func _put(item: Node) -> void:
	contents.append(item)
	add_child(item)
	contents_names.append(item.name)
	if item is AbstractThrowable: # could be plate, food
		item.restore_original_transform()


## Client-side method to put item, called by host
## @param item_name: The name of the item to put
## @param player_id: The id of the player who is putting the item
@rpc("authority", "call_remote", "reliable")
func _client_put(item_name: String, player_id: int) -> void:
	# First try to find item in player's hand
	var player = GlobalScript.get_local_player_by_id(player_id)
	if player:
		var item = player.item_in_hand
		if item and item.name == item_name:
			player.remove_item()
			_put(item)
			return


## Remove and return the last item from this appliance
## @return: The Node that was removed, or null if nothing to take
func take() -> Node:
	if contents.is_empty() or contents_names.is_empty():
		return null
	var item = contents.pop_back()
	remove_child(item)
	contents_names.pop_back()
	return item


## Client-side method to take item, called by host
## @param item_name: The name of the item to take
@rpc("authority", "call_remote", "reliable")
func _client_take(item_name: String) -> void:
	for i in range(contents.size()):
		if contents[i].name == item_name:
			var item = contents.pop_at(i)
			remove_child(item)
			get_tree().current_scene.add_child(item)
			break


## Check if this appliance can accept the given item
## @param item: The Node to test for acceptance
## @return: True if item can be placed, false otherwise
func _can_accept(item: Node) -> bool:
	if not item:
		Debug.all("Cannot accept item, item is null")
		return false
	if contents_names.size() >= capacity:
		Debug.all("Cannot accept item: " + get_script().get_global_name() + " is full")
		return false
	if not item.get_script():
		Debug.all("Cannot accept item, item has no script")
		return false
	return true # Minimum requirement


## Start action process, and unable further actions until it completes
## Subclasses may wrap this method with intuitive name to implement specific action behavior
## @return: True if action started
func start_action() -> bool:
	if current_status != Status.IDLE:
		return false
	if contents.is_empty():
		Debug.warning("No items to act on")
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

## Request to put an item onto this appliance from Player
## @param item: The Node to place on this appliance
func put_request(item: Node) -> void:
	# locally check first to reduce network calls
	if not _can_accept(item):
		return
	# host directly put item and notify clients
	if ENetManager.is_host():
		GlobalScript.get_local_player().remove_item()
		_put(item)
		_client_put.rpc(item.name, ENetManager.get_my_id())
		_sync_contents.rpc(contents_names)
		return
	_put_as_host.rpc_id(1, ENetManager.get_my_id(), item.name)


## Host-side method to handle put requests from clients
## @param player_id: The id of the player who is putting the item
## @param item_name: The name of the item to put
@rpc("any_peer", "call_remote", "reliable")
func _put_as_host(player_id: int, item_name: String) -> void:
	if not ENetManager.is_host():
		return
	# host need check to prevent conflicts/ cheating
	var player = GlobalScript.get_local_player_by_id(player_id)
	if not player:
		Debug.warning("Player not found with id: " + str(player_id))
		return
	var item = player.item_in_hand
	if not _can_accept(item):
		return
	if item.name != item_name:
		Debug.warning("Item name mismatch: expected " + item_name + ", got " + item.name)
		return
	player.remove_item()
	_put(item)
	_client_put.rpc(item.name, player_id)
	_sync_contents.rpc(contents_names)


## Request to take an item from this appliance to Player
func take_request() -> void:
	# locally check first to reduce network calls
	if contents.is_empty() or contents_names.is_empty():
		return
	_take_as_host.rpc_id(1, ENetManager.get_my_id())


## Host-side method to handle take requests from clients
## @param player_id: The id of the player who is taking the item
@rpc("any_peer", "call_local", "reliable")
func _take_as_host(player_id: int) -> void:
	if not ENetManager.is_host():
		return
	# host need check to prevent conflicts/ cheating
	if contents.is_empty() or contents_names.is_empty():
		return
	var item = take()
	get_tree().current_scene.add_child(item)
	_client_take.rpc(item.name)
	_give_item_to_player.rpc(player_id, item.get_path())
	_sync_contents.rpc(contents_names)


# Client-side method to give item to player, called by host
## @param player_id: The id of the player who is taking the item
## @param item_path: The NodePath of the item to give
@rpc("authority", "call_local", "reliable")
func _give_item_to_player(player_id: int, item_path: NodePath) -> void:
	var item = get_node_or_null(item_path)
	if item:
		var player = GlobalScript.get_local_player_by_id(player_id)
		if player:
			player.pickup_item(item)


## Sync contents names across network
## @param update: The updated contents names array
@rpc("authority", "call_remote", "reliable")
func _sync_contents(update: Array[String]) -> void:
	contents_names = update


# Non-networking methods for Player interaction ----------------------------------------------------
## Place an item onto this appliance from Player
## if we could remove Player dependency from this class, we can remove this method
## @param item: The Node to place on this appliance
## @return: True if placement was successful, false otherwise
func put_from_player(item: Node) -> bool:
	if not _can_accept(item):
		return false
	# transfer item to appliance
	GlobalScript.get_local_player().remove_item()
	contents.append(item)
	add_child(item)
	contents_names.append(item.name)
	return true
#---------------------------------------------------------------------------------------------------
