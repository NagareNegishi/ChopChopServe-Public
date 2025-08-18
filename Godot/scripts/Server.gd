class_name Server extends Node

var _services: Dictionary = {} # Contains all services that need to communicate
var _food_court_scene = preload("res://FoodCourt.tscn")
var _test_without_server = false # For running alternative scenes to main

## Adds service to dictionary of known services
func register_service(service_name: String, service_instance):
	if service_name in _services:
		return false
	_services[service_name] = service_instance
	return true
## Removes service from dictionary of known services
func unregister_service(service_name: String):
	if service_name not in _services:
		return false
	_services.erase(service_name)
	return true

## Uses id to get service reference
func get_service(service_id: String):
	return _services.get(service_id, null)

## Useful for failsafe responses
func has_service(service_name: String) -> bool:
	return service_name in _services

## Calls function in a given service 
func call_service(target_service: String, operation: String, params: Array = []):
	var service = get_service(target_service)
	# Useful checks to ensure services are set up and called correctly
	if service == null:
		print("Error: Service '%s' not found" % target_service)
		return null
	if not service.has_method(operation):
		print("Error: Service '%s' does not support operation '%s'" % [target_service, operation])
		return null
	# Calls function from service and returns result
	var result = await service.callv(operation, params)
	return result

# For setting up main game scene
func _ready():
	if !_test_without_server:
		var food_court = _food_court_scene.instantiate()
		food_court.initialize(self, "FoodCourt")
		add_child(food_court)
		var customer_creator = CustomerCreator.new(self)
		register_service("CustomerCreator", customer_creator) 
		register_service("FoodCourt", food_court) 
		var building = Building.new(self)
		await get_tree().create_timer(1.0).timeout
	
	
	

		
