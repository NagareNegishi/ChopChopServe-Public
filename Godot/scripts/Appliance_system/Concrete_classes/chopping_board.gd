## ChoppingBoard is a type of Cookware that allows players to chop food items.
## Unlike other Cookware, it does not require any power source to operate.
## Chopping is triggered by player interaction.
## ChoppingBoard can only hold one food item at a time.
## ChoppingBoard can not be picked up, and always on ChopTable.
class_name ChoppingBoard
extends Cookware

# -----------------------------------------------------------------------------
# TODO: Move the variable to appropriate class
# ADDED so we know how much we need to scale the model on the chopping board by
var food_scale_factor: float = 4
# TODO: Move the function to appropriate class (No need to override)
# ADDED so that when you take the food from the chopping board the scale goes back to how it was
func take() -> Node:
	var item = super.take()
	if item and item is Food:
		item.scale /= food_scale_factor
	return item
# -----------------------------------------------------------------------------

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/items/choppingboard.glb")

## Setup the fryer properties
func _ready():
	super._ready()
	interactable_component.is_pickup = false
	cooking_style = ApplianceFactory.CookingStyle.CHOP
	valid_food = ["Fish", "Tomato", "Potato"] # Confirm later!!!!!!!!!!!!!!
	capacity = 1 # one item only
	coefficient = 1.0


## Add interactable component to this class
## InteractableComponent is scene dependent, can not instantiate from script
func _setup_interactable():
	super._setup_interactable()
	interactable_component.has_action = true


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
	contents.append(item)
	add_child(item)
	item.position = Vector3(0.0, size.y * 0.5, 0.0)
	return true


## Perform cooking logic
## @param power: The power from PoweredAppliance
func cook(power: int) -> bool:
	for food in contents:
		food.startCooking(int(power * coefficient), cooking_style)
	return true


## For Player interaction --------------------------------------------------------------------------

## Place an item onto this appliance
## @param item: The Node to place on this appliance
## @return: True if placement was successful, false otherwise
func put_from_player(item: Node) -> bool:
	if not _can_accept(item):
		return false
	# transfer item to appliance
	GlobalScript.player.remove_item()
	contents.append(item)
	add_child(item)
	item.position = Vector3(0.0, size.y * 0.5, 0.0)
	# -------------------------------------------------------------------------
	# TODO: Move the function to appropriate class
	# ADDED to scale the food to be on the chopping board to be visible
	if item is Food:
		item.scale *= food_scale_factor
	# -------------------------------------------------------------------------
#--------------------------------------------
	print("Put: ", item.get_script().get_global_name(), " onto: ", get_script().get_global_name())
#--------------------------------------------
	return true


## Trigger action, if subclass has action
func _on_interactable_component_action_use(_is_action: bool) -> void:
	if _is_action:
		cook(1)
	else:
		finish_cook()
#---------------------------------------------------------------------------------------------------