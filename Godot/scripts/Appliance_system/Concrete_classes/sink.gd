## Sink only accept plate, player can clean plate in sink manually
class_name Sink
extends UnPoweredAppliance

var water_scene: PackedScene = preload("res://scripts/Food/IngredientScenes/Water.tscn")
var bubble_particles: ParticleController

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/furniture/BenchSink.glb")


## Setup the sink properties
func _ready():
	super._ready()
	capacity = 4
	# action_interval = 1.0
	_setup_visual_effects()
	_set_affixes()
	if not (water_scene and water_scene.can_instantiate()):
		push_error("Failed to preload water scene in Sink")


## Add synchronization properties for the placeable object
func _add_sync_properties(config: SceneReplicationConfig):
	super._add_sync_properties(config)
	config.add_property(NodePath(".:supply_count"))


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


## Trigger the washing process
## @return: True if washing started
func wash() -> bool:
	return start_action()


## Provide water, register it with unique name
## @return: The Water instance provided
func _provide_water() -> Water:
	var water = water_scene.instantiate()
	water.name = prefix + "Water" + str(supply_count)
	supply_count += 1
	ApplianceManager.register_item(water, current_owner, water.name)
	return water


## Check if this appliance can accept the given item
## @param item: The Node to test for acceptance
## @return: True if item can be placed, false otherwise
func _can_accept(item: Node) -> bool:
	var acceptable = super._can_accept(item)
	if not acceptable:
		return false
	return item is Plate


## Perform action logic
func _action() -> bool:
	if current_status != Status.USING:
		assert(false, "Do not call wash() unless status is USING")
		return false
	
	for item in contents:
		# if item is Plate:
		if item.has_method("clean"):
			item.clean()
		else:
			push_error("Sink can only clean plates, found: " + item.get_class())
	return true


## For Player interaction --------------------------------------------------------------------------

## Perform action depend on what player is holding
## @param _item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(item: Node) -> void: # we may need player or id as parameter for multiplier!!!!!!!!!!!!!!!!!!
	# If player has nothing: move Plate from Sink to player (if exists)
	if not item:
		take_request()
		return

	# If Player has Pot, provide water
	if item is Pot:
		#--------------------------------------------
		print("Provide water to pot")
		#TODO: check what is goint on, I see the comment "item removed" after this
		#--------------------------------------------
		item.put_request(_provide_water())
		return

	# If player has empty plate: depend on if sink can accept it
	put_request(item)


## Trigger action, if subclass has action
func _on_interactable_component_action_use(_is_action: bool) -> void:
	print("Player used action on: ", get_script().get_global_name(), ", it can wash.")
	if _is_action:
		wash()
		_toggle_bubble(true)
	else:
		_toggle_bubble(false)


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
		highlight_component.set_state(ApplianceHighlight.HighlightState.HOVER)
		return
	var can_accept = _can_accept(item) or (item is Pot and not item.is_full())
	highlight_component.show_feedback(can_accept)
#---------------------------------------------------------------------------------------------------
