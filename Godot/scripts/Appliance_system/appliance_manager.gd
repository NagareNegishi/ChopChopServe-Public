# appliance_manager.gd
## Manages the lifecycle of appliances in the game
## Player must request appliances through this manager
extends Node

var team1_appliances: Array[Appliance] = []
var team2_appliances: Array[Appliance] = []
var shared_appliances: Array[Appliance] = [] # if this concept is needed


## Player requests new Appliance
## @param type: The type of appliance to request
## @param team: The team ID (1 or 2) to assign the appliance to
## @return: The created Appliance instance or null if creation failed
func request_appliance(type: String, team: int = 0) -> Appliance:
	if not ApplianceFactory.book.has(type):
		push_error("Appliance type '%s' not registered!" % type)
		return null
	var price = ApplianceFactory.book[type].price

	## here ask money management to if they can afford it-----------------------
	var can_afford = true
	#---------------------------------------------------------------------------
	if not can_afford:
		print("Team %d cannot afford '%s'" % [team, type])
		return null
	var appliance = ApplianceFactory._create_appliance(type)
	register_appliance(appliance, team)
	return appliance


## Register an appliance with the manager
## @param appliance: The appliance instance to register
## @param team: The team ID (1 or 2) to register the appliance under
func register_appliance(appliance: Appliance, team: int = 0) -> void:
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


