extends Node3D

################################################################################
# TODO:
	# - Check that this is actually working
	# - Make sure this networking !!
################################################################################

# Check this time is good !!
var secs = 10.0
var things

var appliances
@onready var rat_attack = RatAttack

func power_outage(teamID: int) -> void:
	# Get the appliances within the scene
	appliances = get_tree().get_nodes_in_group("flammable")
	# Remove the Applianes from the other team
	for a in appliances:
		if a.get_appliance_owner() == teamID:
			appliances.erase(a)
	# Turn the power off
	turn_power_off(false)
	# Start the timer
	start_timer()

# Turn the PoweredAppiances off
func turn_power_off(is_power_on: bool) -> void:
	# Go through and find the powered ones
	for appliance in appliances:
		if appliance is PoweredAppliance and appliance.has_method("power_off"):
			if is_power_on:
				# Turn the power on
				appliance.power_on()
			else:
				# Otherwise turn it off
				appliance.power_off()

# Timer for the fire spreading
func start_timer() -> void:
	var timer = Timer.new()
	timer.wait_time = secs
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

# When the timer ends, spread the fire
func _on_timer_timeout() -> void:
	print("jess: time is ending")
	# Turn the Power back on
	turn_power_off(true)
	