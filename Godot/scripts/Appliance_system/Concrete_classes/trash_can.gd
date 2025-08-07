## Trash Can only accept food items, player can throw food in trash can manually
## Items in trash can will be removed instantly
## Nothing can be taken from trash can
##
## Note: the implementation can be simplify by extending Appliance directly,
## however, considering the future extension, I will extend UnPoweredAppliance
class_name TrashCan
extends UnPoweredAppliance


func _ready():
	super._ready()
	# valid_classes = [Food]
	# capacity = 10
	# action_interval = 0.1 ## maybe small amount to avoid rapidly throwing items?


## Override unsupported methods to prevent misuse
func take() -> Node:
	assert(false, "TrashCan does not support taking items")
	return null

func take_at(_index: int) -> Node:
	assert(false, "TrashCan does not support taking items")
	return null


## Trigger the throwing process
## @return: True if throwing started
func throw(item: Node) -> bool:
	if put(item):

		# we could directly free the item here, if state management is not needed
		return start_action()
	return false


## Perform action logic
func _action() -> bool:
	if current_status != Status.USING:
		assert(false, "Do not call wash() unless status is USING")
		return false
	for item in contents:
		# if item is Food:
		if item.has_method("is_food"):
			item.queue_free()
	contents.clear()
	return true