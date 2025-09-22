extends Node3D
class_name FireStart

# Function to start the fire
func start_fire(teamID: int, chosen_path: NodePath) -> void:
	print("Starting fire for team %s on %s" % [teamID, chosen_path])
	# Get the appliance
	var appliance = get_node_or_null(chosen_path)
	# Otherwise, just return
	if not appliance:
		push_warning("Chosen appliance path is invalid: %s" % chosen_path)
		return
		
	# Start the fire if it has an inflammable component
	if "inflammable_component" in appliance and appliance.inflammable_component:
		appliance.inflammable_component.ignite()
	else:
		push_warning("Chosen appliance has no inflammable component")
		return
		
	# Maybe change this to erase the stuff instead
	# But also it ignite class might already do something to the food ?!
	# Burn any food in the appliance
	# Updated the code 19.09.25 to erase the food rather than burn it
	for item in appliance.contents:
		# Get the cookware of appliance
		if item is Cookware:
			# Get its items
			for food in item.contents:
				item.contents.erase(food)
				remove_child(food)
				food.queue_free()

				# ----- OG code ----- #
				# If it is food, burn it
				##food.state = Food.foodState.BURNT
				# update its state
				##if food.has_method("on_state_change"):
					##food.on_state_change()
