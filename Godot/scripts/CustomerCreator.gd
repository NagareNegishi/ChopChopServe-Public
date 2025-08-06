class_name CustomerCreator extends Node

# Reference to create customers from
var _customer_packed_scene = preload("res://NPCs/Customer.tscn")
var _game_server: Server # For communications with other services
var _next_id: int = 0 # Allows for customers to be uniquely indentified

## Ensures server can be referenced
func _init(server = null):
	if server != null:
		_game_server = server

## Creates unique customer with reference to which restaurant its in
func create_customer(restaurant_id: String):
	var customer = _customer_packed_scene.instantiate()
	_game_server.register_service("Customer_" + str(_next_id), customer)
	_game_server.call_service("Customer_" + str(_next_id), "initialize", 
								[_game_server, "Customer_" + str(_next_id), 
								restaurant_id])
	_next_id += 1
	return customer
	
