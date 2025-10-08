extends Node3D
class_name FireStart

################################################################################
# TODO:
	# - Check if I need to do anything with food in the appliances
	# - Do something if all of the appliances are on fire or if it goes on to long
################################################################################

var path
var teamID
var secs = 15.0 # Change this if we need to

# Signal to say the fire can spread
signal fire_spread( teamID: int, appliance_path: NodePath)

# Function to start the fire
func start_fire(team_ID: int, chosen_path: NodePath) -> void:
	# Get the appliance
	var appliance = get_node_or_null(chosen_path)
	teamID = team_ID
	path = chosen_path
	start_timer()
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
	
### --------- Think Inflammable has this code in it already --------- ###
	# Burn the food inside the appliances
	##for item in appliance.contents:
		# Get the cookware of appliance
		##if item is Cookware:
			# Get its items
			##for food in item.contents:
				##item.contents.erase(food)
				##remove_child(food)
				##food.queue_free()

# Timer for the fire spreading
func start_timer() -> void:
	var timer = Timer.new()
	timer.wait_time = secs
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	SabotageSystem.sabotage_start.emit("Fire Spread", secs)

# When the timer ends, spread the fire to other appliances
func _on_timer_timeout() -> void:
	fire_spread.emit(teamID, path)
	SabotageSystem.sabotage_ending.emit("Fire Spread")
	
	

	
