## Sink only accept plate, player can clean plate in sink manually
class_name Sink
extends UnPoweredAppliance


func _ready():
	super._ready()
	# valid_classes = ???
	# capacity = ???
	# action_interval = ???


func wash() -> bool:
	return start_action()


func _action() -> bool:
	if current_status != Status.USING:
		assert(false, "Do not call wash() unless status is USING")
		return false
	
	for item in contents:
		if item is Plate:
			item.clean()
		else:
			push_error("Sink can only clean plates, found: " + item.get_class())
	
	return true
