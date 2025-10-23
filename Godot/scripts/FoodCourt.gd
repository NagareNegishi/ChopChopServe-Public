class_name FoodCourt extends Node


const NEW_CUSTOMER_DELAY: float = 1.5
const QUEUE_CHECK_DELAY: float = 0.5
var _time_since_last_customer: float = 0.5
var _time_since_queue_check: float = 0.0


@onready var _game_server = get_node("/root/GameServer")
@onready var sabotage_system = get_node("/root/SabotageSystem")
@export var customer_scenes: Array[PackedScene] = []
@export var tables: Array[Table] = []
@export var queue_spots: Array[QueueSpot] = []
@export var customer_spawn_point: Node3D
@export var customer_exit_point: Node3D
@export var customer_seed = 0 # For making synced random changes

var _next_customer_id_num: int = 0
var number_of_restaurants = 2


func _ready():
	# Add to a group to be easily found by ENetManager
	add_to_group("FoodCourt")
	_game_server.register_service(name, self)
	sabotage_system.connect("spawn_critic", spawn_food_critic)
	# Initialize tables and queue spots so they can be found by the game server
	var _next_id = 0
	for occupiable in tables + queue_spots:
		occupiable.initialize(str("FoodCourt", "occupiable_", _next_id))
		_game_server.register_service(str("FoodCourt", "occupiable_", _next_id), occupiable)
		_next_id += 1
	
func _process(delta: float):
	if not is_multiplayer_authority():
		return
	if customer_seed == 0:
		customer_seed = randi()
	# Shifts queue if there are any gaps
	_time_since_queue_check -= delta
	if _time_since_queue_check < 0:
		_time_since_queue_check = QUEUE_CHECK_DELAY
		for i in range(queue_spots.size() - 1):
			var occupant = await _game_server.call_service(queue_spots[i].id(), "occupied_with", [])
			if not occupant:
				shift_queue(i)
				
	_time_since_last_customer -= delta
	if _time_since_last_customer < 0 and (GameState.get_customer_check() 
									and await get_free_queue_spot()
									and customer_seed != 0):
		_time_since_last_customer = NEW_CUSTOMER_DELAY
		var customer_id = "customer_%d" % _next_customer_id_num
		_next_customer_id_num += 1
		
		# Ensure the spawn point exists
		if not customer_spawn_point.is_inside_tree():
			return 
		
		var spawn_position = customer_spawn_point.global_position
		var food_court_id = self.name
		# Call the RPC to spawn the customer on all clients (and the server)
		spawn_customer.rpc(customer_id, spawn_position, food_court_id)

func spawn_food_critic(teamID: int):
	print("I AM CONNECTED", teamID)
	var customer_id = "customer_%d" % _next_customer_id_num
	var spawn_position = customer_spawn_point.global_position
	var food_court_id = self.name
	_next_customer_id_num += 1
	spawn_customer.rpc(customer_id, spawn_position, food_court_id, true, teamID % 2 + 1)
@rpc("any_peer", "call_local", "reliable")
func spawn_customer(id: String, pos: Vector3, fc_id: String, is_critic=false, crit_id=-1):
	# prevent duplicate customers from being spawned
	if get_node_or_null(id):
		return
	var new_customer
	if is_critic:
		customer_scenes[customer_seed % customer_scenes.size()].instantiate()
		new_customer = customer_scenes[customer_seed % customer_scenes.size()].instantiate()
	else:
		pass
	new_customer.name = id
	new_customer._id = id
	new_customer._food_court_id = fc_id
	add_child(new_customer)
	new_customer.global_position = pos
	
	# Tell the multiplayer system that the server (peer ID 1) has authority.
	new_customer.set_multiplayer_authority(1)
	if is_multiplayer_authority():
		customer_seed = randi()
## Returns point customers despawn at
func get_exit_point():
	return customer_exit_point
	
## finds a table without a customer
func get_free_table():
	if not tables.filter(func(table): return not await _game_server.call_service(table.id(), "occupied", [])):
		return null
		
	var table = tables.filter(func(table): return not await _game_server.call_service(table.id(), "occupied", [])).pick_random()
	_game_server.call_service(table.id(), "set_occupied", [true])
	return table

## finds a queue spot without a customer
func get_free_queue_spot(customer = null):
	for i in range(queue_spots.size()):
		var occupant = await _game_server.call_service(queue_spots[i].id(), "occupied_with", [])
		if not occupant or occupant == customer:
			return queue_spots[i]
	return null

## Shifts all customers in the queue closer to the front
func shift_queue(start = 0):
	for i in range(start, queue_spots.size()):
		var occupant = await _game_server.call_service(queue_spots[i].id(), "occupied_with", [])
		if occupant:
			var customer_node = _game_server.get_service( occupant)
			if is_instance_valid(customer_node):
				customer_node.move_up_queue(queue_spots[i - 1])
## Indicates whether a given id matches the queues front
func is_queue_front(id):
	return queue_spots.front().id() == id
