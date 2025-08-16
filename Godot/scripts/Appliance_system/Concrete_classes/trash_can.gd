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
## @return: True if throwing started
func throw(item: Node) -> bool:
	if _can_accept(item):
		if current_status != Status.IDLE:
			#--------------------------------------------
			print("Trash Can is busy.")
			#--------------------------------------------
			return false
		current_status = Status.USING
		status_changed.emit(current_status)
		action_timer.start()
		# Remove from player and destroy immediately
		GlobalScript.player.remove_item()
		item.queue_free()
		#--------------------------------------------
		print("Threw away: ", item.get_script().get_global_name())
		#--------------------------------------------
		return true
	#--------------------------------------------
	print("Can not throw away: ", item.get_script().get_global_name())
	#--------------------------------------------
	return false


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
#-------------------------------------------------------------------------------


## Check if this appliance can accept the given item
## @param item: The Node to test for acceptance
## @return: True if item can be placed, false otherwise
func _can_accept(item: Node) -> bool:
	if not item:
		print("Cannot accept item, item is null")
		return false
	# if current_status == Status.BROKEN:  probably never broke? then i should override broken() later
	# 	print("Cannot accept item, appliance is broken")
	# 	return false
	# if contents.size() >= capacity:
	# 	print("Cannot accept item, appliance is at full capacity")
	# 	return false
	return item is Food


## Perform action depend on what player is holding
## @param _item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(item: Node) -> bool: # we may need player or id as parameter for multiplier!!!!!!!!!!!!!!!!!!
	return throw(item)
