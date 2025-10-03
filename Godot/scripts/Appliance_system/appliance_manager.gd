# appliance_manager.gd
## Manages the lifecycle of appliances in the game
## Player must request appliances through this manager
extends Node

signal appliance_created(appliance: Appliance)

var team1_appliances: Array[Appliance] = []
var team2_appliances: Array[Appliance] = []
var shared_appliances: Array[Appliance] = [] # if this concept is needed
var next_id: int = 0


## Local player requests new Appliance
## @param type: The type of appliance to request
## @param team: The team ID (1 or 2) to assign the appliance to
func request_appliance(type: String, team: int = 0) -> void:
	if not ApplianceFactory.book.has(type):
		push_error("Appliance type '%s' not registered!" % type)
		return
	if not ENetManager.is_host():
		_request_appliance_to_host.rpc_id(1, type, team)
		return
	_provide_appliance_as_host(type, team)


## Client sends appliance request to host
## @param type: The type of appliance to request
## @param team: The team ID (1 or 2) to assign the appliance to
@rpc("any_peer", "call_remote", "reliable")
func _request_appliance_to_host(type: String, team: int):
	_provide_appliance_as_host(type, team)


## Host checks if the request can be granted
## @param type: The type of appliance to provide
## @param team: The team ID (1 or 2) to assign the appliance to
func _provide_appliance_as_host(type: String, team: int):
	if not ENetManager.is_host():
		Debug.net_log("_provide_appliance_as_host should only be called on the host!")
		return
	var price = ApplianceFactory.book[type].price

	# if team == 0:
	# 	var appliance_name = _generate_appliance_name(type, team)
	# 	notify_appliance_created.rpc(type, team, appliance_name)
	# 	return

	# Check if the team can afford the appliance
	if not CurrencySystem.can_afford(team, price):
		Debug.info("Team %d cannot afford '%s'" % [team, type])
		return
	var appliance_name = _generate_appliance_name(type, team)

	notify_appliance_created.rpc(type, team, appliance_name)



## Notify all players (include host) what appliances should be created in the game
## Instantiation of new appliances will be executed locally
## @param type: The type of appliance to create
## @param team: The team ID (1 or 2) to assign the appliance to
## @param appliance_name: The name of the appliance
@rpc("authority", "call_local", "reliable")
func notify_appliance_created(type: String, team: int, appliance_name: String):
	var appliance = ApplianceFactory._create_appliance(type)
	register_appliance(appliance, team, appliance_name)
	appliance_created.emit(appliance)


## Generate a unique name for the appliance (Host only)
## @param type: The type of appliance to create
## @param team: The team ID (1 or 2) to assign the appliance to
func _generate_appliance_name(type: String, team: int) -> String:
	next_id += 1
	return "T%d_%s_%d" % [team, type, next_id]


## Register an appliance with the manager
## @param appliance: The appliance instance to register
## @param team: The team ID (1 or 2) to register the appliance under
## @param appliance_name: The name of the appliance
func register_appliance(appliance: Appliance, team: int, appliance_name: String) -> void:
	if not appliance:
		push_error("Cannot register a null appliance!")
		return
	# If using a .tscn file, it should already have an owner and name set
	if not appliance.using_tscn:
		appliance.set_appliance_owner(team)
		appliance.name = appliance_name
	match team:
		1: team1_appliances.append(appliance)
		2: team2_appliances.append(appliance)
		_: shared_appliances.append(appliance)


## Unregister an appliance from the manager
## @param appliance: The appliance instance to unregister
func unregister_appliance(appliance: Appliance) -> void:
	team1_appliances.erase(appliance)
	team2_appliances.erase(appliance)
	shared_appliances.erase(appliance)


## Destroy an appliance and free its resources
## @param appliance: The appliance instance to destroy
func destroy_appliance(appliance: Appliance) -> void:
	unregister_appliance(appliance)
	if appliance.get_parent():
		appliance.get_parent().remove_child(appliance)
	appliance.queue_free()


## Get a list of appliances for a specific team
## @param team: The team ID (1 or 2)
func get_team_appliances(team: int = 0) -> Array[Appliance]:
	match team:
		1: return team1_appliances.duplicate()
		2: return team2_appliances.duplicate()
		_: return shared_appliances.duplicate()


## Reset all appliances for new stage
func reset_appliances() -> void:
	team1_appliances.clear()
	team2_appliances.clear()
	shared_appliances.clear()
	next_id = 0