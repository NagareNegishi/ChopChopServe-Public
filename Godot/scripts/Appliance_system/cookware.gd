## Kitchen equipment class Container
## Used by PoweredAppliance, like a Pot, Pan, etc.
## Cookware must be used by PoweredAppliance, it will not work alone
class_name Cookware
extends Equipment

var power_receiving: int = 0
var sizzle_particles: ParticleController

## Setup the cookware
func _ready():
	super._ready()
	interactable_component.is_pickup = true
	_setup_visual_effects()


## Setup visual effects
func _setup_visual_effects():
	sizzle_particles = ParticleController.create_with_effect(ParticleController.EffectType.SIZZLE)
	sizzle_particles.position.y = size.y * 0.8
	add_child(sizzle_particles)
	sizzle_particles.set_scale_multiplier(2.0)


## Place an item onto this appliance
## @param item: The Node to place on this appliance
## @return: True if placement was successful, false otherwise
func put(item: Node) -> bool:
	var success = super.put(item)
	if success: # and item is Food:
		_put_food(item)
	return success


## Place an item onto this appliance
## @param item: The Node to place on this appliance
func _put(item: Node) -> void:
	super._put(item)
	if item is Food:
		_put_food(item)


## Place an item onto this appliance
## @param item: The Node to place on this appliance
## @return: True if placement was successful, false otherwise
func put_all(items: Array) -> bool:
	if not _can_accept_all(items):
		return false
	for item in items:
		put(item)
	return true


## Place food into the cookware
## @param food: The Food item to place into the cookware
func _put_food(food: Food) -> void:
	#food.current_visibility(false)
	food.change_collisions()
	if can_cook():
		# _average_food() # depend on Food implementation ---------------------------
		food.startCooking(int(power_receiving * coefficient), cooking_style)
		_average_food()
		_toggle_sizzle(true)
	print("Food placed in cookware: ", food.get_script().get_global_name(), ", Cookware can cook: ", can_cook(), ", Food cook time: ", food.get_cook_time(cooking_style))


## Average cooking time of food in cookware
## Only subclass of Food should be in Cookware
## Note: Do not call when contents is empty (Food has different default cooking time)
## @return: The average cooking time of all food items in the cookware
func _average_food() -> float:
	if contents.size() == 1:
		return contents[0].get_cook_time(cooking_style)
	var total = 0.0
	for food in contents:
		total += food.get_cook_time(cooking_style)
	var average = total / contents.size()
	for food in contents:
		food.set_cook_time(average, cooking_style)
	return average


## Remove and return all items
## @return: Array of all items that were removed
func take_all() -> Array[Node]:
	finish_cook()
	var all_items = contents
	for item in all_items:
		remove_child(item)
	contents = []
	contents_names = []
	return all_items


## Check if this appliance can accept the all given items
## @param items: The Array of Nodes to test for acceptance
## @return: True if all items can be placed, false otherwise
func _can_accept_all(items: Array) -> bool:
	if items.is_empty():
		print("Cannot accept items, its empty")
		return false
	if contents.size() + items.size() > capacity:
		print("Cannot accept items: ", get_script().get_global_name(), " is at full capacity")
		return false
	for item in items:
		if not item.get_script().get_global_name() in valid_food:
			return false
	return true


## Perform cooking logic
## @param power: The power from PoweredAppliance
func cook(power: int) -> bool:
	if not can_cook():
		return false
	power_receiving = power
	for food in contents:
		food.startCooking(int(power_receiving * coefficient), cooking_style)
		# #-----------------------------------------------------------------------
		# print(get_script().get_global_name(), " start cooking ", food.get_script().get_global_name(),
		#  " with power: ", int(power_receiving * coefficient), ", Style is: ",
		# ApplianceFactory.CookingStyle.keys()[cooking_style], ", Food cook time: ", food.get_cook_time(cooking_style))
		# #----------------------------------------------------------------------
	_toggle_sizzle(true)
	return true


## Finish cooking process
## @return: True if cooking finished
func finish_cook() -> bool:
	var success = super.finish_cook()
	if success:
		_toggle_sizzle(false)
	return success


## Toggle sizzle particles effect
func _toggle_sizzle(sizzle: bool) -> void:
	if sizzle:
		sizzle_particles.play()
	else:
		sizzle_particles.stop()


## For Player interaction --------------------------------------------------------------------------

## Perform action depend on what player is holding
## @param item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(item: Node) -> void:
	if item is Plate:
		serve_request(item)
		return
	super.player_has(item)


## Check if the plate can accept the current contents
## @param plate: The Node to check for acceptance
## @return: True if the plate can accept the current contents, false otherwise
func _check_plate(plate: Plate) -> bool:
	if is_empty():
		print("Nothing to serve from: ", get_script().get_global_name())
		return false
	if plate.is_ready():
		return true
	return false


## Serve food from Cookware to Plate
## @param plate: The Plate to serve food to
func serve_request(plate: Plate) -> void:
	# locally check first to reduce network calls
	if not _check_plate(plate):
		return
	if ENetManager.is_host():
		plate.add_list_items(take_all()) # Method in Plate, takes Array of Food
		_client_serve.rpc(ENetManager.get_my_id())
		return
	_serve_as_host.rpc_id(1, ENetManager.get_my_id())


## Host-side method to handle serve requests from clients
## @param player_id: The id of the player who is serving the food
@rpc("any_peer", "call_remote", "reliable")
func _serve_as_host(player_id: int) -> void:
	if not ENetManager.is_host():
		return
	var plate = GlobalScript.get_local_player_by_id(player_id).item_in_hand
	if not plate or not (plate is Plate):
		print("Player is not holding a plate")
		return
	if not _check_plate(plate):
		return
	plate.add_list_items(take_all()) # Method in Plate, takes Array of Food
	_client_serve.rpc(player_id)


## Client-side method to serve food to plate, called by host
## @param player_id: The id of the player who is serving the food
@rpc("authority", "call_remote", "reliable")
func _client_serve(player_id: int) -> void:
	var plate = GlobalScript.get_local_player_by_id(player_id).item_in_hand
	if plate and plate is Plate and _check_plate(plate):
		plate.add_list_items(take_all())


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


## Non-networking methods for Player interaction ---------------------------------------------------
# ## Place an item onto this appliance from Player
# ## if we could remove Player dependency from this class, we can remove this method
# ## @param item: The Node to place on this appliance
# ## @return: True if placement was successful, false otherwise
# func put_from_player(item: Node) -> bool:
# 	var success = super.put_from_player(item)
# 	if success: # and item is Food:
# 		_put_food(item)
# 	return success

# ## Serve food from Cookware to Plate
# ## @param plate: The Plate to serve food to
# ## @return: True if serving was successful, false otherwise
# func serve_to_plate(plate: Plate) -> bool:
# 	if contents.is_empty():
# 		print("Nothing to serve from: ", get_script().get_global_name())
# 		return false

# 	if not plate.is_ready():	# Method in Plate, checks if plate is ready
# 		print("Plate is not ready: ", plate.get_script().get_global_name())
# 		return false

# 	plate.add_list_items(take_all())	# Method in Plate, takes Array of Food
# 	return true
## -------------------------------------------------------------------------------------------------
