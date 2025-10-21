## Kitchen equipment class Container
## Used by PoweredAppliance, like a Pot, Pan, etc.
## Cookware must be used by PoweredAppliance, it will not work alone
class_name Cookware
extends Equipment


@onready var cookware_ui_scene : PackedScene = preload("res://UI/UI_Contents.tscn")
@onready var sprite_ref : Sprite3D = Sprite3D.new()
@onready var viewport : SubViewport = SubViewport.new()

var cookware_ui : UIContents
var power_receiving: int = 0
var sizzle_particles: ParticleController
var smoke_particles: ParticleController
# Food positioning
var food_slots: Array[Vector3] = []
var center_offset: Vector3 = Vector3.ZERO
var spacing: float = 0.15
var random_range: float = 0.03
var food_scale: Vector3 = Vector3(0.7, 0.7, 0.7)


## Setup the cookware
func _ready():
	super._ready()
	interactable_component.is_pickup = true
	_setup_visual_effects()
	_setup_cookware_ui()
	_setup_food_slots()


## Setup visual effects
func _setup_visual_effects():
	sizzle_particles = ParticleController.create_with_effect(ParticleController.EffectType.SIZZLE)
	sizzle_particles.position.y = size.y * 0.8
	add_child(sizzle_particles)
	sizzle_particles.set_scale_multiplier(2.0)
	smoke_particles = ParticleController.create_with_effect(ParticleController.EffectType.SMOKE)
	smoke_particles.position.y = size.y * 0.8
	add_child(smoke_particles)
	smoke_particles.set_scale_multiplier(2.0)


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
	food.change_collisions(true)
	cookware_ui.add_food(food)
	food.restore_original_transform()
	food.entered_danger_zone.connect(_on_food_started_burning)
	_position_food(food)
	emit_signal("food_placed", self, contents)
	if can_cook():
		food.start_cooking(int(power_receiving * coefficient), cooking_style)
		_average_food()
		_toggle_sizzle(true)
	Debug.cook_log("Food placed in cookware: " + food.get_script().get_global_name()
		+ ", Cookware can cook: " + str(can_cook()) + ", Food cook time: " + str(food.get_cook_time(cooking_style)))


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
	emit_signal("new_average", average)
	return average


## Remove and return all items
## @return: Array of all items that were removed
func take_all() -> Array[Node]:
	finish_cook()
	var all_items = contents
	for item in all_items:
		if item is Food:
			item.entered_danger_zone.disconnect(_on_food_started_burning)
		remove_child(item)
	contents = []
	contents_names = []
	cookware_ui.clear()
	emit_signal("food_taken",self, all_items)
	return all_items


## Check if this appliance can accept the all given items
## @param items: The Array of Nodes to test for acceptance
## @return: True if all items can be placed, false otherwise
func _can_accept_all(items: Array) -> bool:
	if items.is_empty():
		Debug.all("Cannot accept items, its empty")
		return false
	if contents.size() + items.size() > capacity:
		Debug.all("Cannot accept items: " + name + " is full")
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
		food.start_cooking(int(power_receiving * coefficient), cooking_style)
	_toggle_sizzle(true)
	return true


## Finish cooking process
## @return: True if cooking finished
func finish_cook() -> bool:
	var success = super.finish_cook()
	if success:
		_toggle_sizzle(false)
		_toggle_smoke(false)
	return success


## Handle food started burning signal
func _on_food_started_burning() -> void:
	_toggle_smoke(true)


## Toggle sizzle particles effect
func _toggle_sizzle(sizzle: bool) -> void:
	if sizzle:
		sizzle_particles.play()
	else:
		sizzle_particles.stop()


## Toggle smoke particles effect
func _toggle_smoke(smoke: bool) -> void:
	if smoke:
		smoke_particles.play()
	else:
		smoke_particles.stop()


## Toggle visibility of food in cookware
## @param can_see: True if food should be visible, false otherwise
func toggle_food_visibility(can_see: bool) -> void:
	for food in contents:
		food.current_visibility(can_see)


## Calculate food slots positions
func _setup_food_slots():
	for i in range(capacity):
		var slot_position = _calculate_food_position(i, center_offset)
		food_slots.append(slot_position)


## Apply position to food at given slot
## @param food: The Food item to position
func _position_food(food: Food) -> void:
	var slot_index = contents.size() - 1
	if slot_index < food_slots.size():
		var base_position = food_slots[slot_index]
		var random_offset = Vector3(
			randf_range(-random_range, random_range),
			randf_range(-random_range, random_range),
			randf_range(-random_range, random_range)
		)
		food.position = base_position + random_offset
		food.scale = food_scale


## Calculate position for food at given index
## @param index: The index of the food item
## @param center: The center offset of the cookware
## @return: The position for the food item
func _calculate_food_position(index: int, center: Vector3) -> Vector3:
	if capacity == 1:
		return center
	# Make a grid layout from capacity
	var cols = ceil(sqrt(capacity))
	var row = floor(index / cols)
	var col = index % int(cols)
	# Center the grid
	var offset_x = (col - (cols - 1) / 2.0) * spacing
	var offset_z = (row - (cols - 1) / 2.0) * spacing
	return center + Vector3(offset_x, 0, offset_z)

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
		Debug.cook_log("Nothing to serve from: " + get_script().get_global_name())
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
		Debug.all("Player is not holding a plate")
		return
	if not _check_plate(plate):
		return
	plate.add_list_items(take_all()) # Method in Plate, takes Array of Food
	_client_serve.rpc(player_id)
	emit_signal("food_taken")


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
	emit_signal("food_taken", self, contents)
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


## Setup the cookware UI
func _setup_cookware_ui():
	cookware_ui = cookware_ui_scene.instantiate()
	viewport.transparent_bg = true
	sprite_ref.texture = viewport.get_texture()
	sprite_ref.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	self.add_child(sprite_ref)
	sprite_ref.add_child(viewport)
	viewport.add_child(cookware_ui)
	sprite_ref.global_position += Vector3(0,0.5,0)
