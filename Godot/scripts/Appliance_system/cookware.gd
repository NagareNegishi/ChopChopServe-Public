## Kitchen equipment class Container
## Used by PoweredAppliance, like a Pot, Pan, etc.
## Cookware must be used by PoweredAppliance, it will not work alone
class_name Cookware
extends Equipment

var power_receiving: int = 0
var sizzle_particles: ParticleController

## Setup the cookware
func _ready():
	super._ready()
	interactable_component.is_pickup = true
	_setup_visual_effects()


## Setup visual effects
func _setup_visual_effects():
	sizzle_particles = ParticleController.create_with_effect(ParticleController.EffectType.SIZZLE)
	sizzle_particles.position.y = size.y * 0.8
	add_child(sizzle_particles)
	sizzle_particles.set_scale_multiplier(2.0)


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
	#food.current_visibility(false)
	food.change_collisions()
	if can_cook():
		# _average_food() # depend on Food implementation ---------------------------
		food.startCooking(int(power_receiving * coefficient), cooking_style)
		_average_food()
		_toggle_sizzle(true)
	print("Food placed in cookware: ", food.get_script().get_global_name(), ", Cookware can cook: ", can_cook(), ", Food cook time: ", food.get_cook_time(cooking_style))


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
		print("Total cooking time in cookware: ", total)#!!!!!!!!!!!!!!
	var average = total / contents.size()
	print("Average cooking time in cookware: ", average)#!!!!!!!!!!!!!!
	for food in contents:
		print("Setting food cook time from: ", food.get_cook_time(cooking_style), " to average: ", average) #!!!!!!!!!!!!!!
		food.set_cook_time(average, cooking_style)
		print("After setting food cook time: ", food.get_cook_time(cooking_style))#!!!!!!!!!!!!!!
	return average


## Perform cooking logic
## @param power: The power from PoweredAppliance
func cook(power: int) -> bool:
	if not can_cook():
		return false
	power_receiving = power
	for food in contents:
		food.startCooking(int(power_receiving * coefficient), cooking_style)
		#-----------------------------------------------------------------------
		print(get_script().get_global_name(), " start cooking ", food.get_script().get_global_name(),
		 " with power: ", int(power_receiving * coefficient), ", Style is: ",
		ApplianceFactory.CookingStyle.keys()[cooking_style], ", Food cook time: ", food.get_cook_time(cooking_style))
		#----------------------------------------------------------------------
	_toggle_sizzle(true)
	return true


## Finish cooking process
## @return: True if cooking finished
func finish_cook() -> bool:
	var success = super.finish_cook()
	if success:
		_toggle_sizzle(false)
	return success


## Toggle sizzle particles effect
func _toggle_sizzle(sizzle: bool) -> void:
	if sizzle:
		sizzle_particles.play()
	else:
		sizzle_particles.stop()


## For Player interaction --------------------------------------------------------------------------

## Place an item onto this appliance from Player
## if we could remove Player dependency from this class, we can remove this method
## @param item: The Node to place on this appliance
## @return: True if placement was successful, false otherwise
func put_from_player(item: Node) -> bool:
	var success = super.put_from_player(item)
	if success: # and item is Food:
		_put_food(item)
	return success


# TODO??
# if we don't want to serve food to plate, when cookware is floor or not specified location
# we can comment out method below:

## Perform action depend on what player is holding
## @param item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(item: Node) -> bool:
	if item is Plate:
		return serve_to_plate(item)
	return super.player_has(item)


## Serve food from Cookware to Plate
## @param plate: The Plate to serve food to
## @return: True if serving was successful, false otherwise
func serve_to_plate(plate: Plate) -> bool:
	if contents.is_empty():
		print("Nothing to serve from: ", get_script().get_global_name())
		return false

	if not plate.is_ready():	# Method in Plate, checks if plate is ready
		print("Plate is not ready: ", plate.get_script().get_global_name())
		return false

	finish_cook()
	plate.add_list_items(take_all())	# Method in Plate, takes Array of Food
	#----------------------------------------------------------------------
	print("Cookware :", get_script().get_global_name(), ", served to: ", plate.get_script().get_global_name())
	#----------------------------------------------------------------------
	return true
## -------------------------------------------------------------------------------------------------


