class_name UpgradeHammer extends AbstractThrowable

signal upgrade()

@onready var interact_comp : InteractableComponent = $InteractableComponent
@onready var player : Player = GlobalScript.get_local_player()
@onready var upgrade_effect : GPUParticles3D 
@onready var _upgrade_effect_scene : PackedScene
@onready var _particle_effect : GPUParticles3D = $Sparkle
@onready var _upgrade_ui : Sprite3D = $UpgradeUI

var upgrade_library : Dictionary[Appliance, Upgradable] = {} #Dict of all appliances and their chosen upgrade
var _comp : InteractableComponent #Used purely so player can upgrade with needing rehover ovetr appliance

## Called when the node enters the scene tree for the first time.
## @return void
func _ready() -> void:
	interact_comp.local_action_use.connect(_can_upgrade)
	_particle_effect.emitting = false
	_upgrade_ui.visible = false
	remove_child(_particle_effect)
	await get_tree().create_timer(2).timeout
	remove_child(_upgrade_ui)
	get_tree().current_scene.add_child.call_deferred(_upgrade_ui)


## Called when interacted with, it connects signal to find upgrade when hovered and item dropped
func _on_interactable_component_interacted():
	super._on_interactable_component_interacted()
	GlobalScript.get_local_player().comp_hovered.connect(_store_upgrade)
	GlobalScript.get_local_player().item_dropped.connect(_disconnect_signal)


func _can_upgrade(is_action : bool):
	if (GlobalScript.get_local_player()._closest_item == null ||
	!GlobalScript.get_local_player()._closest_item.get_parent() is Appliance): return
	var appliance : Appliance = GlobalScript.get_local_player()._closest_item.get_parent() 
	
	if (appliance == null || !(appliance is Appliance) || 
	(appliance.current_owner != 0 && appliance.current_owner != ENetManager.get_my_team())): 
		return
	
	if !upgrade_library.has(appliance) || !_can_purchase(appliance):  
		return
	
	_show_ui(false, appliance.global_position)
	
	rpc("_play_effect", upgrade_library.get(appliance).get_parent().global_position)
	rpc("_animation", GlobalScript.get_local_player().get_path())

	_upgrade(upgrade_library.get(appliance))
	
	
func _store_upgrade(comp : InteractableComponent, is_hover : bool):
	if !comp.get_parent() is Appliance || !is_hover: 
		_show_ui(false)
		return
	
	_comp = comp 
	var appliance : Appliance = comp.get_parent()
	
	if appliance.current_owner != ENetManager.get_my_team(): 
		_show_ui(false, appliance.global_position)
		return
	
	if upgrade_library.has(appliance):
		_show_ui(true, appliance.global_position)
		return 

	var upgrades = _get_valid_upgrades(appliance)
	
	if upgrades.is_empty():
		_show_ui(false)
		return
	
	upgrade_library[appliance] = upgrades.pick_random()
	_show_ui(true, appliance.global_position)

##Disconnects the hover signal and item dropped signal
## @param item item that was dropped
func _disconnect_signal(item : Node3D):
	GlobalScript.get_local_player().comp_hovered.disconnect(_store_upgrade)
	GlobalScript.get_local_player().item_dropped.disconnect(_disconnect_signal)


##Checks if player can purchase the appliance upgrade
## @param appliance appliance to check if player can purchase
## @return bool returns true if can purchase
func _can_purchase(appliance : Appliance) -> bool:
	assert(appliance != null, "appliance is null")
	return CurrencySystem.check_currency(ENetManager.get_my_team(), upgrade_library[appliance].get_upgrade_cost()) 


##Replicated the animations so all players see the hammer animation
## @param player_path path to the players node in the tree
@rpc("any_peer", "call_local")
func _animation(player_path : String):
	var player : Player = get_tree().current_scene.get_node(player_path) #sets variables to play hammer animation
	player.anim_tree["parameters/conditions/action"] = true
	player.anim_tree["parameters/conditions/unaction"] = false
	player.anim_tree["parameters/SM_ACTION/conditions/whacking"] = true
	player.disable_controls(true, true)
	player.item_in_hand.visible = false
	
	await get_tree().create_timer(1.1).timeout #Hardcoded time to wait for animation...

	player.disable_controls(false, false) #sets variables to return to normal animation
	player.item_in_hand.visible = true
	player.anim_tree["parameters/SM_ACTION/conditions/whacking"] = false
	player.anim_tree["parameters/conditions/unaction"] = true
	player.anim_tree["parameters/conditions/action"] = false


## Actually upgrades the appliance
## @param upgrade the upgradable that is going to be upgraded
func _upgrade(upgrade : Upgradable):
	assert(upgrade, "upgrade is null")
	
	var appliance : Appliance = upgrade.get_parent() 
	upgrade.request_upgrade(ENetManager.get_my_id())
	upgrade_library.erase(appliance)
	_show_ui(false)
	#if _comp: _store_upgrade(_comp, true) #Checks if can upgrade again


## Finds all valid upgrades within an appliance
## @param app appliance that will be upgraded
## @return Array[Upgradable] list of valid upgrades
func _get_valid_upgrades(app : Appliance) -> Array[Upgradable]:
	assert(app != null, "appliance reference is null")

	var res : Array[Upgradable] = [app.capacity_upgradable, app.power_upgradable]
	
	return res.filter(func(a : Upgradable): #Filters for valid upgrades
		return a.can_upgrade() && a.enabled && a.current_level < a.max_level)


@rpc("any_peer", "call_local")
func _play_effect(location : Vector3):
	var effect : GPUParticles3D = _particle_effect.duplicate()
	get_tree().current_scene.add_child(effect)
	effect.global_position = location + Vector3(0,0.5,0)
	effect.emitting = true
	await get_tree().create_timer(2).timeout
	effect.emitting = false
	await get_tree().create_timer(2).timeout
	effect.queue_free()


func _show_ui(is_visible : bool, location : Vector3 = Vector3(0,0,0)):
	_upgrade_ui.global_position = location+ Vector3(0,0.5,0)
	_upgrade_ui.visible = is_visible


func _set_ui_info(upgrade : Upgradable, app : Appliance):
	pass
