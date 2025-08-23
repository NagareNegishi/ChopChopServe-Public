class_name FoodCourt extends Node

const SECOND_FROM_QUEUE_BACK = 3

# Maximum times and timers relating to customers
const NEW_CUSTOMER_DELAY : float = 1.5
const QUEUE_CHECK_DELAY : float = 0.5
var _time_since_last_customer : float = 0
var _time_since_queue_check : float = 0.5

var _game_server: Server # For communications with other services
var _next_id : int  = 0 # Allows for occupiables to be uniquely indentified
var _id # For unique indentification for other services

var number_of_restaurants = 2

@export var tables : Array[Table] = [] # Where customers can order from
@export var queue_spots: Array[QueueSpot] = [] # Where customers will queue
@export var customer_spawn_point : Node3D # Where customers spawn
@export var customer_exit_point : Node3D # Where customers leave food court to
## Initialize restaurant with server and communication ids
func initialize(game_server : Server, id : String) -> void:
	_game_server = game_server
	_id = id

## Preprares restaurants occupiables for communications
func _ready():
	for occupiable in tables + queue_spots:
		occupiable.initialize(str(_id,"occupiable_",_next_id))
		_game_server.register_service(str(_id,"occupiable_",_next_id), occupiable)
		_next_id += 1

func get_exit_point():
	return customer_exit_point

## Returns a randomly selected free table or null if all are occupied	
func get_free_table():
	# Checking for free tables
	if !tables.filter(
		func(table): 
			return !await _game_server.call_service(table.id(), "occupied", [])):
		return null
		
	# Occupying and returning random table
	var table = tables.filter(
		func(table): 
			return !await _game_server.call_service(table.id(),
													"occupied", [])).pick_random()
	_game_server.call_service(table.id(), "set_occupied", [])
	return table
	
## Returns the closest free spot to the front of the queue
func get_free_queue_spot(customer = null):
	for i in range(queue_spots.size()):
		var occupant = await _game_server.call_service(queue_spots[i].id(), 
													"occupied_with", [])
		if !occupant || occupant == customer:
			return queue_spots[i]

## Checks whether a new customer should spawn or queue should move forward
func _process(delta):
	# Shifts queue if there are any gaps
	_time_since_queue_check -= delta
	if _time_since_queue_check < 0:
		_time_since_queue_check = QUEUE_CHECK_DELAY
		for i in range(0, queue_spots.size() - 1):
			var occupant = await _game_server.call_service(queue_spots[i].id(),
														"occupied_with", [])
			if !occupant:
				shift_queue(i)
				
	# Spawns new customers when there is space in queue
	_time_since_last_customer -= delta
	if _time_since_last_customer < 0 && await get_free_queue_spot():
		var new_customer = await _game_server.call_service("CustomerCreator",
														"create_customer", [_id, number_of_restaurants])
		add_child(new_customer)
		new_customer.position = customer_spawn_point.position
		_time_since_last_customer += NEW_CUSTOMER_DELAY

## Gets each customer currently in queue to move forward
func shift_queue(start = 0):
	for i in range(start, queue_spots.size()):
		var occupant = await _game_server.call_service(queue_spots[i].id(),
														"occupied_with", [])
		if occupant:
			_game_server.call_service(occupant, "move_up_queue", 
										[queue_spots[i - 1]])
	return null
	
## Returns true if customer is at the front of queue
func is_queue_front(id):
	return queue_spots.front().id() == id
