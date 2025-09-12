## MultiFoodCrate provides multiple types of ingredient, but takes nothing back.
## player can take food from food crate manually
class_name MultiFoodCrate
extends UnPoweredAppliance

@export_group("Supply Settings")
@export var supplies: Array[PackedScene] = []
@export var supply_names: Array[String] = ["Tomato"]
var food_directory: String = "res://scripts/Food/IngredientScenes/"
var supply_instances: Array[Node] = []
var supply_counts: Array[int] = []


## Set up the FoodCrate
func _ready():
	super._ready()
	action_interval = 0.5 # small interval to avoid rapid item taking
	_set_affixes()
	_initialize_supply()


## Add synchronization properties for the placeable object
func _add_sync_properties(config: SceneReplicationConfig):
	super._add_sync_properties(config)
	config.add_property(NodePath(".:supply_counts"))


## Initialize the supply
## Support people prefer configuring through .tscn
func _initialize_supply():
	# case no supplies configured
	if supplies.is_empty():
		set_supply(supply_names)
		return

	# verify configured supplies
	var is_configured = true
	for supply in supplies:
		if supply and supply.can_instantiate():
			var instance = supply.instantiate()
			supply_instances.append(instance)
			supply_counts.append(1)
		else:
			is_configured = false
	if is_configured:
		return
	
	# default behavior
	push_error("Supplies not properly configured!!, overriding supplies with supply_names")
	supplies.clear()
	supply_instances.clear()
	supply_counts.clear()
	set_supply(supply_names)


## Set the supply script for the food crate
func set_supply(food_names: Array[String]):
	for food_name in food_names:
		var scene_path = food_directory + food_name + ".tscn"
		var supply_scene = load(scene_path)
		if supply_scene and supply_scene.can_instantiate():
			supplies.append(supply_scene)
			supply_instances.append(supply_scene.instantiate())
			supply_counts.append(1)
		else:
			push_error("Failed to load or cannot instantiate scene: " + scene_path)


## Provide food from the crate
## @param index: The index of the food item to take
## @return: The food item that was taken, or null if not in IDLE status
func take_at(index: int) -> Node:
	if current_status != Status.IDLE:
		push_error("FoodCrate is not in IDLE status, cannot take food")
		return null
	if index < 0 or index >= supply_instances.size():
		push_error("Index out of range in take_at: " + str(index))
		return null
	current_status = Status.USING
	action_timer.start()
	var food = supplies[index].instantiate()
	if not food:
		push_error("Failed to instantiate food at index: " + str(index))
		current_status = Status.IDLE
		return null
	food.name = prefix + supply_names[index] + str(supply_counts[index])
	supply_counts[index] += 1
	ApplianceManager.register_item(food, current_owner, food.name)
	return food


## For Player interaction --------------------------------------------------------------------------

#TODO: player_has should take index as well

## Perform action depend on what player is holding
## @param _item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(item: Node) -> void:
	print("pop up UI here")
	player_selected(item, 0)


## Perform action depend on what player is holding
## @param _item: The Node Player is holding
## @param index: The index of the food item to take
## @return: True if action is triggered, false otherwise
func player_selected(item: Node, index: int) -> void:
	if not item:
		take_at_request(index)
		return

	if item is Cookware and item._can_accept(supply_instances[index]):
		transfer_request(item, index)
		return


## Client-side method to take item, called by host
## @param item_name: The name of the item to take
@rpc("authority", "call_remote", "reliable")
func _client_take_at(item_name: String, index: int) -> void:
	var item = take_at(index)
	if not item:
		push_error("Failed to take item at index: " + str(index))
		return
	item.name = item_name
	get_tree().current_scene.add_child(item)


## Request to take an item from this appliance to Player
func take_at_request(index: int) -> void:
	_take_at_as_host.rpc_id(1, ENetManager.get_my_id(), index)


## Host-side method to handle take requests from clients
## @param player_id: The id of the player who is taking the item
@rpc("any_peer", "call_local", "reliable")
func _take_at_as_host(player_id: int, index: int) -> void:
	if not ENetManager.is_host():
		return
	# host need check to prevent conflicts/ cheating
	var item = take_at(index)
	get_tree().current_scene.add_child(item)
	_client_take_at.rpc(item.name, index)
	_give_item_to_player.rpc(player_id, item.get_path())


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


## Transfer food from FoodCrate to Cookware
## @param cookware: The Cookware to transfer food to
func transfer_request(player_cookware: Cookware, index: int) -> void:
	var food = take_at(index)
	if not food:
		return
	if ENetManager.is_host():
		player_cookware._put(food)
		_client_transfer.rpc(ENetManager.get_my_id(), food.name, index)
		return
	_transfer_as_host.rpc_id(1, ENetManager.get_my_id(), index)


## Host-side method to handle transfer requests from clients
## @param player_id: The id of the player who is transferring the food
@rpc("any_peer", "call_remote", "reliable")
func _transfer_as_host(player_id: int, index: int) -> void:
	if not ENetManager.is_host():
		return
	var player_cookware = GlobalScript.get_local_player_by_id(player_id).item_in_hand
	if player_cookware is Cookware and player_cookware._can_accept(supply_instances[index]):
		var food = take_at(index)
		player_cookware._put(food)
		_client_transfer.rpc(player_id, food.name, index)


## Client-side method to transfer food, called by host
## @param player_id: The id of the player who is transferring the food
@rpc("authority", "call_remote", "reliable")
func _client_transfer(player_id: int, food_name: String, index: int) -> void:
	var player_cookware = GlobalScript.get_local_player_by_id(player_id).item_in_hand
	if player_cookware is Cookware and player_cookware._can_accept(supply_instances[index]):
		var food = take_at(index)
		food.name = food_name
		player_cookware._put(food)


## Give visual feedback when hovered
## @param is_hovered: Whether the item is hovered or not
func _on_interactable_component_hovered(is_hovered: bool) -> void:
	if not is_hovered:
		highlight_component.hide_feedback()
		return
	var item = GlobalScript.get_local_player().item_in_hand
	#---------------------------------------------------------------------------
	if item:
		print("Player has : ", item.get_script().get_global_name(), ", hovered: ", get_script().get_global_name())
	#---------------------------------------------------------------------------
	if not item:
		highlight_component.show_feedback(true)
		return
	if item is Cookware:
		if item.is_full():
			highlight_component.show_feedback(false)
		else:
			highlight_component.show_feedback(true)
#---------------------------------------------------------------------------------------------------


## Override unsupported methods to prevent misuse ------------------------------
func put(_item: Node) -> bool:
	assert(false, "Food Crate does not support putting items")
	return false

func take() -> Node:
	assert(false, "MultiFoodCrate requires an index to take specific food item")
	return null

func start_action() -> bool:
	assert(false, "Food Crate does not support starting actions")
	return false

func put_from_player(_item: Node) -> bool:
	assert(false, "Food Crate does not support putting items")
	return false
#-------------------------------------------------------------------------------
