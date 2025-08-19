## Kitchen equipment class Container
## Used by PoweredAppliance, like a Pot, Pan, etc.
## Cookware must be used by PoweredAppliance, it will not work alone
class_name Cookware
extends Equipment

var power_receiving: int = 0

## Setup the cookware
func _ready():
	super._ready()
	interactable_component.is_pickup = true


## Place an item onto this appliance
## @param item: The Node to place on this appliance
## @return: True if placement was successful, false otherwise
func put(item: Node) -> bool:
	var success = super.put(item)
	if success: # and item is Food:
		_put_food(item)
	return success


## Place food into the cookware
## @param food: The Food item to place into the cookware
func _put_food(food: Food) -> void:
	food.current_visibility(false)
	food.change_collisions()
	if current_status == Status.USING:
		average_food()
		food.startCooking(int(power_receiving * coefficient), cooking_style)
	print("Food placed in cookware: ", food.get_script().get_global_name())
	print("Food cook time: ", food.get_cook_time())


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
	power_receiving = power
	for food in contents:
		food.startCooking(int(power_receiving * coefficient), cooking_style)
		#-----------------------------------------------------------------------
		print(get_script().get_global_name(), " start cooking ", food.get_script().get_global_name(),
		 " with power: ", int(power_receiving * coefficient), ", Style is: ",
		ApplianceFactory.CookingStyle.keys()[cooking_style])
		print("Food cook time: ", food.get_cook_time())
		#----------------------------------------------------------------------
	return true


## Perform action depend on what player is holding
## @param item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(item: Node) -> bool:
	#----------------------------------------------------------------------------
	if item:
		print("its : ", item.get_script().get_global_name())
	else:
		print("player has null!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")

	#----------------------------------------------------------------------------
	if item is Plate:
		return serve_to_plate(item)
	return super.player_has(item)



func serve_to_plate(plate: Plate) -> bool: # Node should change to Plate when its ready!!!!!!!!
	if contents.is_empty():
		print("Nothing to serve")
		return false

	# likely need to check if plate is ready here later!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	# Method in Plate, takes Array of Food
	finish_cook()
	plate.add_list_items(take_all())
	#----------------------------------------------------------------------
	print("Cookware :", get_script().get_global_name(), ", served to: ", plate.name)
	#----------------------------------------------------------------------
	return true
