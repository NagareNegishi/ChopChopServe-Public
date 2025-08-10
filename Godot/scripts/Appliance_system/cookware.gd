## Kitchen equipment class Container
## Used by PoweredAppliance, like a Pot, Pan, etc.
## Cookware must be used by PoweredAppliance, it will not work alone
class_name Cookware
extends Equipment


## Setup the cookware
func _ready():
	super._ready()


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
		if food.has_method("cook"): ## Check the method name!!!!!!!!!!!!!!!!!!!!!!!!
			food.cook(power * coefficient, cooking_style)
		else:
			push_warning("Item " + food.name + " does not implement cook() method")
	return true





func serve_to_plate(plate: Node) -> bool: # Node should change to Plate when its ready!!!!!!!!
	if contents.is_empty():
		push_warning("Nothing to serve")
		return false
	if not plate:
		push_warning("Cannot serve to null")
		return false
	if plate.has_method("is_ready"):
		if not plate.is_ready():
			push_warning("Cannot serve to non-ready plate") # maybe not empty? maybe dirty??
			return false
		var dish = ApplianceFactory.match_menu_items(take_all())
		if plate.has_method("add_dish"):
			plate.add_dish(dish)
			print("Cookware served dish to plate: ", plate.name)
			return true

	push_warning("Plate does not provide required methods")
	return false