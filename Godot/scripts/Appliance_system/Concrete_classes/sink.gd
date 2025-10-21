## Sink only accept plate, player can clean plate in sink manually
## The Status must be always IDLE. DO NOT FORCEFULLY CHANGE!!
class_name Sink
extends UnPoweredAppliance

var bubble_particles: ParticleController
signal progress()

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/newmodels/furniture/Sink.glb")
	appliance_name = "Sink"


## Setup the sink properties
func _ready():
	super._ready()
	capacity = 1
	_setup_visual_effects()
	# see the NOTE: 8/10/2025 below --------------------------------------------
	# _set_affixes()
	# if not (water_scene and water_scene.can_instantiate()):
	# 	push_error("Failed to preload water scene in Sink")
	# --------------------------------------------------------------------------


## Add interactable component to this class
## InteractableComponent is scene dependent, can not instantiate from script
func _setup_interactable():
	super._setup_interactable()
	interactable_component.has_action = true


## Setup visual effects
func _setup_visual_effects():
	bubble_particles = ParticleController.create_with_effect(ParticleController.EffectType.BUBBLE)
	bubble_particles.position.y = size.y * 0.8
	add_child(bubble_particles)
	bubble_particles.set_scale_multiplier(2.0)


## Override upgradable setup in concrete appliances
func _setup_upgradable():
	super._setup_upgradable()
	enable_upgrade("capacity", [1, 1, 1], [80, 160, 240])


## Toggle bubble particles effect
func _toggle_bubble(bubble: bool) -> void:
	if bubble:
		bubble_particles.play()
	else:
		bubble_particles.stop()


## Check if this appliance can accept the given item
## @param item: The Node to test for acceptance
## @return: True if item can be placed, false otherwise
func _can_accept(item: Node) -> bool:
	var acceptable = super._can_accept(item)
	if not acceptable:
		return false
	return item is Plate and item.is_empty()


## Trigger the washing process
func start_wash() -> void:
	if contents.is_empty():
		Debug.cook_log("Sink has nothing to wash")
		return
	action_timer.start()
	_toggle_bubble(true)
	SoundManager.play_sfx_cooking(SoundManager.SFX_COOKING.WASH)


## Stop the washing process
func stop_wash() -> void:
	action_timer.stop()
	_toggle_bubble(false)

var clean:int

## Timer callback to handle action logic
func _on_action_timer_timeout():
	clean = clean + 1
	emit_signal("progress")
	if clean == 3:
		for plate in contents:
			if plate is Plate:
				plate.clean()


## Override unsupported methods to prevent misuse ------------------------------
func start_action() -> bool:
	assert(false, "Sink does not support generic action, use start_wash() instead")
	return false


## For Player interaction --------------------------------------------------------------------------

## Perform action depend on what player is holding
## @param _item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(item: Node) -> void:
	# If player has nothing: move Plate from Sink to player (if exists)
	if not item:
		take_request()
		return
	# see the NOTE: 8/10/2025 below --------------------------------------------
	# # If Player has Pot, provide water
	# if item is Pot:
	# 	supply_water_request(item)
	# 	return
	# --------------------------------------------------------------------------
	# If player has empty plate: depend on if sink can accept it
	put_request(item)


## Trigger action, if subclass has action
func _on_interactable_component_action_use(_is_action: bool) -> void:
	if _is_action:
		start_wash()
	else:
		stop_wash()


## Give visual feedback when hovered
## @param is_hovered: Whether the item is hovered or not
func _on_interactable_component_hovered(is_hovered: bool) -> void:
	if not is_hovered:
		highlight_component.hide_feedback()
		return
	var item = GlobalScript.get_local_player().item_in_hand
	if item:
		Debug.all("Player ID: " + str(ENetManager.get_my_id())
			+ " has : " + item.get_script().get_global_name() + ", hovered: " + get_script().get_global_name())
	if not item:
		highlight_component.set_state(ApplianceHighlight.HighlightState.HOVER)
		return
	var can_accept = _can_accept(item) # or (item is Pot and not item.is_full())
	highlight_component.show_feedback(can_accept)
#---------------------------------------------------------------------------------------------------


## NOTE: 8/10/2025
# the team removed water from cooking, therefore Sink no longer needs to supply water to Pot.
# However, I will keep the water supply code here for future reference, in case we want to reintroduce it. -------------

# var water_scene: PackedScene = preload("res://scripts/Food/IngredientScenes/Water.tscn")

# ## Add synchronization properties for the placeable object
# func _add_sync_properties(config: SceneReplicationConfig):
# 	super._add_sync_properties(config)
# 	config.add_property(NodePath(".:supply_count"))

# ## Provide water, register it with unique name
# ## @return: The Water instance provided
# func _provide_water() -> Water:
# 	var water = water_scene.instantiate()
# 	water.name = prefix + "Water" + str(supply_count)
# 	supply_count += 1
# 	return water

# ## Supply water from Sink to Pot
# ## @param pot: The Pot to supply water to
# func supply_water_request(pot: Pot) -> void:
# 	# locally check first to reduce network calls
# 	if pot.is_full():
# 		return
# 	if ENetManager.is_host():
# 		var water = _provide_water()
# 		pot._put(water)
# 		_client_supply_water.rpc(ENetManager.get_my_id(), water.name)
# 		pot._sync_contents.rpc(pot.contents_names)
# 		return
# 	_supply_water_as_host.rpc_id(1, ENetManager.get_my_id())

# ## Host-side method to handle water supply requests from clients
# ## @param player_id: The id of the player who is requesting water
# @rpc("any_peer", "call_remote", "reliable")
# func _supply_water_as_host(player_id: int) -> void:
# 	if not ENetManager.is_host():
# 		return
# 	var pot = GlobalScript.get_local_player_by_id(player_id).item_in_hand
# 	if not pot or not (pot is Pot) or pot.is_full():
# 		return
# 	var water = _provide_water()
# 	pot._put(water)
# 	_client_supply_water.rpc(player_id, water.name)
# 	pot._sync_contents.rpc(pot.contents_names)

# ## Client-side method to supply water, called by host
# ## @param player_id: The id of the player who requested water
# ## @param water_name: The unique name of the water item
# @rpc("authority", "call_remote", "reliable")
# func _client_supply_water(player_id: int, water_name: String) -> void:
# 	var pot = GlobalScript.get_local_player_by_id(player_id).item_in_hand
# 	if pot and pot is Pot and not pot.is_full():
# 		var water = water_scene.instantiate() # Skip registration, already done by host
# 		water.name = water_name
# 		pot._put(water)


func _on_dish_taken():
	pass # Replace with function body.
