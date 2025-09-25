class_name Server extends Node

var _services: Dictionary = {}

func _ready():
	# Service registration will now be handled by the nodes themselves when they are ready.
	# For example, FoodCourt will register "FoodCourt", and each Customer will register itself.
	var customer_creator = CustomerCreator.new(self)
	register_service("CustomerCreator", customer_creator)
	
	var order_generator = generateOrder.new()
	register_service("OrderGenerator", order_generator)

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

## Calls function in a given service 
func call_service(target_service: String, operation: String, params: Array = []):
	var service = get_service(target_service)
	if service == null:
		print("Not found service" + target_service + operation)
		return null
	if not service.has_method(operation):
		return null
	var result = await service.callv(operation, params)
	return result
