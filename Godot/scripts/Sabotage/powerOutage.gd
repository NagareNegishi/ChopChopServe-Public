extends Node3D

# Turn the PoweredAppiances off
func turn_power_off(teamID: int):
    # Use teamID to get what teams kitchen to do
	var appliances = get_tree().get_nodes_in_group("flammable")
	print("powered appliances \n \n", appliances)
	# Go through and find the powered ones
	for appliance in appliances:
		if appliance is PoweredAppliance && appliance.has_method("power_off"):
			# Turn the power off
			appliance.power_off()
			# WOULD I NEED TO DEAL WITH POTENTUAL FOOD THERE?
			print("my state is:", appliance.current_status)
		else:
			print("Warning: ", appliance.name, " doesn't have power_off method")

