## Sink only accept plate, player can clean plate in sink manually
class_name Sink
extends UnPoweredAppliance


func _ready():
	super._ready()
	# valid_classes = ???
	# capacity = ???
	# action_interval = ???


## Trigger the washing process
## @return: True if washing started
func wash() -> bool:
	return start_action()


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
