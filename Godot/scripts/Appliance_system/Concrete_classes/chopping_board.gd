class_name ChoppingBoard
extends Cookware

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/items/choppingboard.glb")

## Setup the fryer properties
func _ready():
	super._ready()
	cooking_style = ApplianceFactory.CookingStyle.CHOP
	valid_food = ["Fish", "Tomato"] # Confirm later!!!!!!!!!!!!!!
	capacity = 4
	coefficient = 1.0


# ------------------------------------------------------------------------------
# may need to override them
# assuming no cooking but chop???

# ## Perform cooking logic
# ## This method should be overridden in subclasses to implement specific cooking behavior
# ## @param power: The power from PoweredAppliance or Player
# func cook(_power: int) -> bool:
# 	assert(false, "cook() must be implemented in " + get_class())
# 	# if current_status != Status.COOKING:
# 	#     assert(false, "Do not call cook() unless status is COOKING")
# 	#     return false
# 	return true


# ## Finish cooking process
# ## @return: True if cooking finished
# func finish_cook() -> bool:
# 	if current_status != Status.USING:
# 		push_warning("Cannot finish cooking unless appliance is using")
# 		return false
# 	current_status = Status.IDLE
# 	status_changed.emit(current_status)
# 	for item in contents:
# 		#if item.has_method("stopCooking"):   #is always Food:
# 		item.stopCooking()
# 	#----------------------------------------------------------------------
# 		print("stopCooking() is called in: ", item.get_script().get_global_name())
# 	#----------------------------------------------------------------------
# 	return true
#
# ## Perform action depend on what player is holding
# ## @param _item: The Node Player is holding
# ## @return: True if action is triggered, false otherwise
# func player_has(item: Node) -> bool:
