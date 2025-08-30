## Trash Can only accept food items, player can throw food in trash can manually
## Items in trash can will be removed instantly
## Nothing can be taken from trash can
##
## Note: the implementation can be simplify by extending Appliance directly,
## however, considering the future extension, I will extend UnPoweredAppliance
class_name TrashCan
extends UnPoweredAppliance


## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/furniture/trashcan.glb")


## Setup the trash can properties
func _ready():
	super._ready()
	action_interval = 0.1 ## maybe small amount to avoid rapidly throwing items?


## Trigger the throwing process
## @param item: The Node to throw away
## @return: True if throwing started
func throw(item: Node) -> bool:
	if _can_accept(item):
		if current_status != Status.IDLE:
			# #--------------------------------------------
			# print("Trash Can is busy.")
			# #--------------------------------------------
			return false
		current_status = Status.USING
		action_timer.start()
		# Remove from player and destroy immediately
		GlobalScript.player.remove_item()
		item.queue_free()
		#--------------------------------------------
		print("Threw away: ", item.get_script().get_global_name())
		#--------------------------------------------
		return true
	# #--------------------------------------------
	# print("Can not throw away: ", item)
	# #--------------------------------------------
	return false


## Trigger the throwing process from Plate or Cookware
## Anything on the plate or cookware can be thrown away
## @param from: The Node to throw away items from
## @return: True if throwing started
func throw_all(from: Node) -> bool:
	if current_status != Status.IDLE:
		return false
	current_status = Status.USING
	action_timer.start()
	var items
	if from is Plate:
		print("Taking all items from Plate")
	elif from is Cookware:
		items = from.take_all()
	for item in items:
		item.queue_free()
	return true


## Check if this appliance can accept the given item
## @param item: The Node to test for acceptance
## @return: True if item can be placed, false otherwise
func _can_accept(item: Node) -> bool:
	var acceptable = super._can_accept(item)
	if not acceptable:
		return false
	return item is Food


## For Player interaction --------------------------------------------------------------------------
## Perform action depend on what player is holding
## @param _item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(item: Node) -> bool: # we may need player or id as parameter for multiplier!!!!!!!!!!!!!!!!!!
	if item is Cookware:
		return throw_all(item)
	return throw(item)


## Give visual feedback when hovered
## @param is_hovered: Whether the item is hovered or not
func _on_interactable_component_hovered(is_hovered: bool) -> void:
	if not is_hovered:
		highlight_component.hide_feedback()
		return
	var item = GlobalScript.player.item_in_hand
	#---------------------------------------------------------------------------
	if item:
		print("Player has : ", item.get_script().get_global_name(), ", hovered: ", get_script().get_global_name())
	#---------------------------------------------------------------------------
	if not item:
		highlight_component.set_state(ApplianceHighlight.HighlightState.HOVER)
		return
	var can_accept = _can_accept(item) or (item is Cookware and not item.is_empty()) or item is Plate
	highlight_component.show_feedback(can_accept)
#---------------------------------------------------------------------------------------------------


## Override unsupported methods to prevent misuse ------------------------------
func put(_item: Node) -> bool:
	assert(false, "TrashCan does not support putting items")
	return false

func take() -> Node:
	assert(false, "TrashCan does not support taking items")
	return null

func start_action() -> bool:
	assert(false, "TrashCan does not support starting actions")
	return false

func put_from_player(_item: Node) -> bool:
	assert(false, "TrashCan does not support putting items")
	return false
#-------------------------------------------------------------------------------