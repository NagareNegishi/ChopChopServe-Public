class_name Blender
extends PoweredAppliance

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/furniture/Blender.glb")


## Setup the blender properties
func _ready():
	super._ready()
	cooking_style = ApplianceFactory.CookingStyle.BLEND
	valid_classes = ["Tomato", "Water"]
	capacity = 4
	power = 1


## Override upgradable setup in concrete appliances
func _setup_upgradable():
	super._setup_upgradable()
	enable_upgrade("power", [1, 1, 1], [100, 200, 300])
	enable_upgrade("capacity", [1, 1, 1], [80, 160, 240])


## Place an item onto this appliance
## @param item: The Node to place on this appliance
## @return: True if placement was successful, false otherwise
func put(item: Node) -> bool:
	if not _can_accept(item):
		return false
	# transfer item to appliance
	GlobalScript.player.remove_item() # if we only put item from players hand
	add_child(item)
	contents.append(item)
	#--------------------------------------------
	print("Put: ", item.get_script().get_global_name(), " onto: ", get_script().get_global_name())
	print("Contents of ", get_script().get_global_name(), " are: ")
	for content in contents:
		print(" --- ", content.get_script().get_global_name())
	#--------------------------------------------
	if item is Food:
		_put_food(item)
	return true


## Place food into the blender
## @param food: The Food item to place into the blender
func _put_food(food: Food) -> void:
	food.current_visibility(false)
	food.change_collisions()
	if current_status == Status.COOKING:
		_average_food()
		food.startCooking(power, cooking_style)
	print("Food placed in blender: ", food.get_script().get_global_name(), ", Food cook time: ", food.get_cook_time(cooking_style))


## Average cooking time of food in cookware
## Only subclass of Food should be in Cookware
## Note: Do not call when contents is empty (Food has different default cooking time)
## @return: The average cooking time of all food items in the cookware
func _average_food() -> float:
	if contents.size() == 1:
		return contents[0].get_cook_time(cooking_style)
	var total = 0.0
	for food in contents:
		total += food.get_cook_time(cooking_style)
	var average = total / contents.size()
	for food in contents:
		food.set_cook_time(average, cooking_style)
	return average


## Remove and return the last item from this appliance
## @return: The Node that was removed, or null if nothing to take
func take() -> Node:
	assert(false, "Use take_all() instead")
	return null


## Remove and return all items
## @return: Array of all items that were removed
func take_all() -> Array[Node]:
	var all_items = contents
	for item in all_items:
		remove_child(item)
	contents = []
	return all_items


## Perform cooking logic
## Blender only takes Food
func _cook() -> bool:
	if is_empty():
		print("No food to blend")
		return false
	for food in contents:
		if food is Food:
			food.startCooking(power, cooking_style)
	return true


## Stop cooking process
## @return: True if cooking stopped
func stop_cook() -> bool:
	if current_status != Status.COOKING:
		push_warning("Cannot stop cooking unless appliance is cooking")
		return false
	for item in contents:
		if item is Food:
			item.stop_cooking()
	#----------------------------------------------------------------------
	print("stop_cook() is called in: ", get_script().get_global_name())
	#----------------------------------------------------------------------
	return true


#---------------------------------------------------------------------------------------------------

## Perform action depend on what player is holding
## @param _item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(item: Node) -> bool: # we may need player or id as parameter for multiplier!!!!!!!!!!!!!!!!!!
#--------------------------------------------
	print("Player has: ", item, ", Self: ", get_script().get_global_name())
#--------------------------------------------
	# If player has nothing, return false
	if not item:
		return false

	# If player has plate: try to serve
	if item is Plate:
		return serve_to_plate(item)

	# If item_in_hand exists: depend on if Blender can accept it
	return put(item)


## Serve food from Cookware to Plate
## @param plate: The Plate to serve food to
## @return: True if serving was successful, false otherwise
func serve_to_plate(plate: Plate) -> bool:
	if contents.is_empty():
		print("Nothing to serve from: ", get_script().get_global_name())
		return false

	if not plate.is_ready(): # Method in Plate, checks if plate is ready
		print("Plate is not ready: ", plate.get_script().get_global_name())
		return false

	plate.add_list_items(take_all()) # Method in Plate, takes Array of Food
	stop_cook()
	#----------------------------------------------------------------------
	print("Blender, served to: ", plate.get_script().get_global_name())
	#----------------------------------------------------------------------
	return true


# Functions for Sabotage System---------------------------------------------------------------------

## Get the current progress of cookwares
## Note: Only use it when PoweredAppliance can be operated
## Note: Progress is defined by the `cook_time` of `Food` -> smaller values are more progressed
## @return: The progress of the cooking process
func get_progress() -> float:
	if is_empty():
		return INF
	return _average_food()
#---------------------------------------------------------------------------------------------------


## InteractableComponent Signal Handlers -----------------------------------------------------------
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
	var can_accept = _can_accept(item)
	highlight_component.show_feedback(can_accept)
## -------------------------------------------------------------------------------------------------
