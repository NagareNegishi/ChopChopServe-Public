## ChoppingBoard is a type of Cookware that allows players to chop food items.
## Unlike other Cookware, it does not require any power source to operate.
## Chopping is triggered by player interaction.
## ChoppingBoard can only hold one food item at a time.
## ChoppingBoard can not be picked up, and always on ChopTable.
class_name ChoppingBoard
extends Cookware

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/items/choppingboard.glb")

## Setup the fryer properties
func _ready():
	super._ready()
	interactable_component.is_pickup = false
	cooking_style = ApplianceFactory.CookingStyle.CHOP
	valid_food = ["Fish", "Tomato"] # Confirm later!!!!!!!!!!!!!!
	capacity = 1 # one item only
	coefficient = 1.0


# ## Override upgradable setup in concrete appliances
# func _setup_upgradable():
# 	super._setup_upgradable()
# 	enable_upgrade("coefficient", [0.2, 0.2, 0.2], [100, 200, 300])
# 	# enable_upgrade("capacity", [1, 1, 1], [80, 160, 240])


## Place an item onto this appliance
## @param item: The Node to place on this appliance
## @return: True if placement was successful, false otherwise
func put(item: Node) -> bool:
	if not _can_accept(item):
		return false
	# transfer item to appliance
	GlobalScript.player.remove_item()
	contents.append(item)
	add_child(item)
	item.position = Vector3(0.0, size.y * 0.5, 0.0)
#--------------------------------------------
	print("Put: ", item.get_script().get_global_name(), " onto: ", get_script().get_global_name())
#--------------------------------------------
	return true


## Perform cooking logic
## @param power: The power from PoweredAppliance
func cook(power: int) -> bool:
	for food in contents:
		food.startCooking(int(power * coefficient), cooking_style)
		#-----------------------------------------------------------------------
		print(get_script().get_global_name(), " start cooking ", food.get_script().get_global_name(),
		 " with power: ", int(power * coefficient), ", Style is: ",
		ApplianceFactory.CookingStyle.keys()[cooking_style], ", Food cook time: ", food.get_cook_time())
		#----------------------------------------------------------------------
	return true


## Trigger action, if subclass has action
func _on_interactable_component_action_use(_is_action: bool) -> void:
	if _is_action:
		print("Player used action on: ", get_script().get_global_name(), ", maybe chop here??.")
		for food in contents:
			print("before chopping: ", food.get_script().get_global_name(), ", cook time: ", food.get_cook_time())
		cook(1) # what is the power from player??
		# for food in contents:
		# 	print("after chopping: ", food.get_script().get_global_name(), ", cook time: ", food.get_cook_time())
		# finish_cook()
		# for food in contents:
		# 	print("after stop chopping: ", food.get_script().get_global_name(), ", cook time: ", food.get_cook_time())


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
