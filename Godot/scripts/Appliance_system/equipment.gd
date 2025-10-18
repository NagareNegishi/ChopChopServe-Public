## Kitchen equipment class
## There are 2 types of equipment:
## 1. Container: Used by PoweredAppliance, like a Pot, Pan, etc.
## 2. Tool: Used with Appliance, like a Knife, Whisk, etc.
## Equipment must be used by PoweredAppliance or Player, it will not work alone
class_name Equipment
extends Appliance


@export_group("Equipment Settings")
@export var coefficient: float = 1.0 ## Cooking efficiency modifier (1.0 = normal)
@export var capacity: int = 1 ## Maximum number of items this appliance can hold / deal with
@export var valid_food: Array[String] = [] ## Class names that can be placed in this equipment

var can_use: bool = false


## Setup the equipment
func _ready():
	super._ready()


## Add synchronization properties for the placeable object
func _add_sync_properties(config: SceneReplicationConfig):
	super._add_sync_properties(config)
	config.add_property(NodePath(".:can_use"))
	config.add_property(NodePath(".:coefficient"))
	config.add_property(NodePath(".:capacity"))


## Rotate equipment by the given angle
## @param angle: Relative rotation angle in radians
## @return: always true
func rotate_by(angle: float) -> bool:
	rotation.y += angle
	return true


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
	emit_signal("food_taken", self, item)
	return item


## Peek at the next item to be taken without removing it
## @return: The Node that would be removed next, or null if nothing to take
func _check_next_take() -> Node:
	return contents.back()


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
	return item.get_script().get_global_name() in valid_food


## Perform cooking logic
## This method should be overridden in subclasses to implement specific cooking behavior
## @param power: The power from PoweredAppliance or Player
func cook(_power: int) -> bool:
	assert(false, "cook() must be implemented in " + get_class())
	return true


## Finish cooking process
## @return: True if cooking finished
func finish_cook() -> bool:
	if is_empty():
		return false
	for item in contents:
		if item is Food:
			item.stop_cooking()
	return true


## Check if this equipment is empty
## @return: True if equipment is empty, false otherwise
func is_empty() -> bool:
	return contents.is_empty()


## Check if this equipment is full
## @return: True if equipment is full, false otherwise
func is_full() -> bool:
	return contents.size() >= capacity


## Show the contents of this equipment
## @return: Array of all items in this equipment as copies
func show_contents() -> Array[Node]:
	return contents.duplicate()


## Check if this equipment can be used
## @return: True if equipment can be used, false otherwise
func can_cook() -> bool:
	return can_use and not is_empty()


## Set the can_use property, Appliance use only
## @param value: True if equipment can be used, false otherwise
func set_can_use(value: bool):
	can_use = value



## For Player interaction --------------------------------------------------------------------------

## Perform action depend on what player is holding
## @param _item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(item: Node) -> void:
	# If player has nothing: let them take self, return true
	if not item:
		pickup_request()
		return
	put_request(item)


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


## Sync contents names across network
## @param update: The updated contents names array
@rpc("authority", "call_remote", "reliable")
func _sync_contents(update: Array[String]) -> void:
	contents_names = update


## Request to pick up this equipment by Player
func pickup_request() -> void:
	_pickup_as_host.rpc_id(1, ENetManager.get_my_id())


## Host-side method to handle pickup request, called by client
## @param player_id: The id of the player who is taking the item
@rpc("any_peer", "call_local", "reliable")
func _pickup_as_host(player_id: int) -> void:
	if not ENetManager.is_host():
		return
	_give_item_to_player.rpc(player_id, self.get_path())


#TODO: if we need to reduce the host load, make this method "any_peer" and skip the _pickup_as_host
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

## -------------------------------------------------------------------------------------------------
