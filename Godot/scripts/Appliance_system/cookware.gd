## Kitchen equipment class Container
## Used by PoweredAppliance, like a Pot, Pan, etc.
## Cookware must be used by PoweredAppliance, it will not work alone
class_name Cookware
extends Equipment


## Setup the cookware
func _ready():
	super._ready()
	interactable_component.is_pickup = true


## Place an item onto this appliance
## @param item: The Node to place on this appliance
## @return: True if placement was successful, false otherwise
func put(item: Node) -> bool:
	var success = super.put(item)
	if success:
		average_food()
	return success


## Average cooking time of food in cookware
## Only subclass of Food should be in Cookware
## Note: Do not call when contents is empty (Food has different default cooking time)
## @return: The average cooking time of all food items in the cookware
func average_food() -> int:
	if contents.size() == 1:
		return contents[0].get_cook_time()
	var total = 0.0
	for food in contents:
		total += food.get_cook_time()
	var average = int(total / contents.size())  # we need to check if we want to float or int!!!!!!!!!!
	for food in contents:
		food.set_cook_time(average)
	return average


## Perform cooking logic
## @param power: The power from PoweredAppliance
func cook(power: int) -> bool:
	if current_status == Status.IDLE:
		current_status = Status.USING
		status_changed.emit(current_status)
	elif current_status != Status.USING:
		assert(false, "Do not call cook() unless status is USING")
		return false
	for food in contents:
		food.startCooking(power * coefficient, cooking_style)
		#-----------------------------------------------------------------------
		print(get_script().get_global_name(), " start cooking ", food.get_script().get_global_name(),
		 " with power: ", power * coefficient, ", Style is: ",
		ApplianceFactory.CookingStyle.keys()[cooking_style])
		#----------------------------------------------------------------------
	return true


## Perform action depend on what player is holding
## @param item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(item: Node) -> bool:
	#----------------------------------------------------------------------------
	print("its here 1 ")
	if not item:
		push_warning("Cannot perform action with null item")
		return false
	print("its : ", item.get_script().get_global_name())
	print("Comparing with 'Plate': ", item.get_script().get_global_name() == "Plate")
	print("Comparing with 'Plate': ", item is Plate)
	#----------------------------------------------------------------------------
	if item is Plate:
		print("its here 2 ")
		return serve_to_plate(item)
	return super.player_has(item)



func serve_to_plate(plate: Plate) -> bool: # Node should change to Plate when its ready!!!!!!!!
	if contents.is_empty():
		print("Nothing to serve")
		return false

	# likely need to check if plate is ready here later!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	# Method in Plate, takes Array of Food
	plate.add_list_items(take_all())
	finish_cook()
	#----------------------------------------------------------------------
	print("Cookware :", get_script().get_global_name(), ", served to: ", plate.name)
	#----------------------------------------------------------------------
	return true
