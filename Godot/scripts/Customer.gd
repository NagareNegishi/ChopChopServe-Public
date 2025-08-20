class_name Customer extends NPC

# Customers wait this long once seated
const MAXIMUM_SEATING_TIME: float = 10
# Customers wait this long till they decide order
const MAXIMUM_ORDER_THINK_TIME: float = 10
# For agent avoidance to prevent getting stuck
const AGENT_STUCK_THRESHOLD: float = 0.15
const STUCK_RECALCULATE_TIME: float = 1.0 
var _stuck_timer: float = 0.0
const MAXIMUM_AVOIDANCE_PRIORITY: float = 0.8
const AVOIDANCE_PRIORITY_RESET_AMOUNT: float = 0.5
const AVOIDANCE_PRIORITY_INCREMENT: float = 0.01

# How far customers should sit from table
const POSITION_IN_FRONT_OF_TABLE: Vector3 = Vector3(0, 0.25 , 0.5)

# Targets for pathfinding
var _table_target: Node3D = null
var _queue_target: Node3D = null

# Customer states
var _seated = false
var _queued = false

# ID to communicate with food court they are in
var _food_court_id

var _restaurant_number : int

# Time starts from being seated 
var _time_till_leaving: float = MAXIMUM_SEATING_TIME
var _time_till_order: float = MAXIMUM_ORDER_THINK_TIME
var order: Array[MenuItem] = [TomatoSoup.new()] # DUMMY CODE TILL ORDER SYSTEM READY

## Initialize Customer with server and communication ids
func initialize(game_server : Server, id: String, 
				food_court_id : String, restaurant_number : int ) -> void:
	_game_server = game_server
	_id = id
	_food_court_id = food_court_id
	_restaurant_number = restaurant_number
## Attempt to accquire unoccupied table to navigate towards
func check_tables() -> void:
	_table_target = await _game_server.call_service(_food_court_id, 
													"get_free_table", [])
	if _table_target:
		_queued = false 
		if _queue_target:
			_game_server.call_service(_queue_target.id(), "set_occupied", [false])

		_game_server.call_service(_food_court_id, "shift_queue", [])
		_game_server.call_service(_table_target.id(), "set_occupied", [true])
		_queue_target = null
		_queued = false
		_current_target = _table_target
		_pathfind_to_target()

## Shift customer to queue spot in front
func move_up_queue(spot_in_front : QueueSpot):
	if _queue_target:
		_game_server.call_service(_queue_target.id(), "set_occupied", [false])
		
	_queue_target = spot_in_front
	_game_server.call_service(_queue_target.id(), "set_occupied", [true, _id])
	_current_target = _queue_target
	_pathfind_to_target()

## Accquire spot in queue to navigate towards
func find_queue_spot() -> void:
	_queue_target = await _game_server.call_service(_food_court_id, 
													"get_free_queue_spot", 
													[_id])	
	_game_server.call_service(_queue_target.id(), "set_occupied", [true, _id])
	_current_target = _queue_target
	_pathfind_to_target()

## Tells navigation agent where and what the target is
func _pathfind_to_target() -> void:
	# Disable the obstacle so it doesn't block its own path
	_nav_obstacle.avoidance_enabled = false
	if !_current_target: 
		find_queue_spot()
	_is_pathfinding = true
	
	if _table_target: # Sits target in front of table
		_nav_agent.target_position = (_current_target.global_position 
									+ POSITION_IN_FRONT_OF_TABLE)
		print(order[0].name_of_meal)  # DUMMY CODE TILL ORDER SYSTEM READY
	else:
		_nav_agent.target_position = _current_target.global_position


func _update_pathfinding(delta: float) -> void:
	# The customer will target another queue spot if their current spot is taken
	if _queue_target: 
		if await _game_server.call_service(_queue_target.id(), "occupied_with") != _id:
			_queue_target = null
			stop_movement()
			find_queue_spot()
			
	if not _is_pathfinding or _current_target == null:
		return
		
	# Check if target has been reached
	var _distance_to_target = global_position.distance_to(_nav_agent.target_position)
	if (_nav_agent.is_navigation_finished() 
		|| _distance_to_target <= PATHFINDING_DISTANCE_THRESHOLD):
			
		if _table_target: # Tweens customer's position in front of table
			var tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(self, "global_position", 
								(_nav_agent.target_position 
								+ POSITION_IN_FRONT_OF_TABLE), 
								0.5)
		_seated = _table_target	
		_queued = _queue_target
		_is_pathfinding = false
		stop_movement()
		# Enable the obstacle now that the Customer has stopped
		_nav_obstacle.avoidance_enabled = true
		return
	
	# Sets customer velocity and direction based on next path position
	var _next_path_position = _nav_agent.get_next_path_position()
	var _direction_to_next = (_next_path_position - global_position).normalized()
	_direction_to_next.y = 0  
	var _intended_velocity = _direction_to_next * SPEED
	_nav_agent.set_velocity(_intended_velocity)
	set_direction(_direction_to_next)
	 # If velocity is very low, assume the agent is stuck.
	if velocity.length() < AGENT_STUCK_THRESHOLD:
		_stuck_timer += delta
		# If stuck for long enough, recalculate the entire path
		if _stuck_timer >= STUCK_RECALCULATE_TIME:
			print("I'm stuck, finding a new path!")
			_pathfind_to_target() # This forces a full recalculation
			_stuck_timer = 0.0 # Reset the timer
	else:
		# If the agent is moving freely, reset the timer.
		_stuck_timer = 0.0
	
## Customers will either:
## - search or move to targets (queue spot or table)
## - shift their position in queue
## - sit at table, eventually leaving
func _npc_behavior(delta: float) -> void:
	
	if _is_pathfinding:
		_update_pathfinding(delta)
		return
	
	if !_current_target:
		_pathfind_to_target()
		
	# Customers who have been seated shall wait till they have to leave
	if _seated:
		
		_time_till_order = max(0, _time_till_order - delta)
		if !_time_till_order:
			_time_till_leaving = max(0, _time_till_leaving - delta)
			if !_time_till_leaving:
				
				_game_server.call_service(_table_target.id(), 
											"set_occupied", 
											[false])
				
				_game_server.call_service(_food_court_id, 
											"leave_from_restaurant", 
											[self])
											
			var food_served = await _game_server.call_service(_table_target.id(), 
											"get_food", 
											[])
			# DUMMY CODE TILL ORDER SYSTEM READY
			if food_served && food_served.name_of_meal == order[0].name_of_meal:  
				_game_server.call_service(_table_target.id(), 
										"remove_food", 
										[])
				
				print("YAY!")
				_time_till_leaving = 2
	
	# Customers who reach the front of the queue should begin looking for tables
	if _queued && _queue_target:
		if await _game_server.call_service(_food_court_id, 
											"is_queue_front", 
											[_queue_target.id()]):
			check_tables()
