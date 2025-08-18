## Sink only accept plate, player can clean plate in sink manually
class_name Sink
extends UnPoweredAppliance


## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/furniture/BenchSink.glb")


## Setup the sink properties
func _ready():
	super._ready()
	capacity = 4
	# action_interval = 1.0


## Trigger the washing process
## @return: True if washing started
func wash() -> bool:
	return start_action()


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


## Perform action depend on what player is holding
## @param _item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(item: Node) -> bool: # we may need player or id as parameter for multiplier!!!!!!!!!!!!!!!!!!
	# If player has nothing: move Plate from Sink to player (if exists), return true
	if not item:
		var plate = take()
		if plate:
			GlobalScript.player.pickup_item(plate)
			#----------------------------------------------------------------------
			print("Player took: ", plate.get_script().get_global_name(), ", from: ", get_script().get_global_name())
			#----------------------------------------------------------------------
			return true
		else:
			print("No plate to take from Sink")
			return false
	# If player has empty plate: depend on if sink can accept it
	return put(item)

