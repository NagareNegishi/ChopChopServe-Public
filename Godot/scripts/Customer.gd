class_name Customer extends NPC

enum CustomerState { IDLE, THINKING, ORDERING }

const MAXIMUM_ORDER_THINK_TIME: float = 1.0
const AGENT_STUCK_THRESHOLD: float = 0.15
const STUCK_RECALCULATE_TIME: float = 1.0
const POSITION_IN_FRONT_OF_TABLE: Vector3 = Vector3(0, 0.25, 0.5)

@export var customer_state: CustomerState = CustomerState.IDLE:
	# Runs on all clients when the state changes.
	set(new_state):
		customer_state = new_state
		if (not is_instance_valid(overhead_ui_order_instance) ||
		not is_instance_valid(overhead_ui_thinking_instance)):
			return 
		match customer_state:
			CustomerState.IDLE:
				overhead_ui_thinking_instance.hide()
				overhead_ui_order_instance.hide()
			CustomerState.THINKING:
				overhead_ui_thinking_instance.show()
				overhead_ui_order_instance.hide()
			CustomerState.ORDERING:
				overhead_ui_thinking_instance.hide()
				overhead_ui_order_instance.show()
				order = await _game_server.call_service("OrderGenerator", 
														"get_simple_order", 
														[order_gen_number])
				overhead_ui_order_instance.set_order(order[0])
				order_gen_number += 1
				
@export var synced_position: Vector3
@export var overhead_ui_order: PackedScene
@export var overhead_ui_thinking: PackedScene
@export var order_gen_number = randi()
@onready var ui_anchor: Marker3D = $OverheadUIAnchor

# Might get changed back to const at some point
var MAXIMUM_SEATING_TIME: float = randf_range(100.0, 300.0)

var _table_target: Node3D = null
var _queue_target: Node3D = null
var _seated = false
var _queued = false
var _food_court_id
var _restaurant_number: int
var order: Array
var _time_till_leaving: float = MAXIMUM_SEATING_TIME
var _time_till_order: float = MAXIMUM_ORDER_THINK_TIME
var _stuck_timer: float = 0.0

var _id
var overhead_ui_order_instance: UIOrder
var overhead_ui_thinking_instance: UIThinking

# Registers to server on hosts end 
func _initialize():
	_game_server.register_service(_id, self)
# Unregisters from server 
func _on_tree_exiting():
	if _game_server:
		_game_server.unregister_service(_id)
		
func _ready():
	hide()
	super._ready()
	var ui_layer = get_tree().get_first_node_in_group("Canvas")
	# Create and add UI elements to scene 
	if ui_layer:
		overhead_ui_order_instance = overhead_ui_order.instantiate()
		overhead_ui_thinking_instance = overhead_ui_thinking.instantiate()
		
		for ui_element in [overhead_ui_order_instance, 
		overhead_ui_thinking_instance]:
			ui_element.scale = Vector2.ONE * 0.5
			ui_element.hide()
			ui_layer.add_child(ui_element)
		
	if not is_multiplayer_authority():
		set_physics_process(false) # physics calculated server side
	else:
		_initialize()

## Syncing position of customer and overhead ui positions 
func _process(_delta):
	if not is_multiplayer_authority():
		position = synced_position
		
	if is_instance_valid(overhead_ui_order_instance):
		overhead_ui_order_instance.progress_bar.set_amount(
								1 - _time_till_leaving / MAXIMUM_SEATING_TIME)
		position_ui(overhead_ui_order_instance)
		
	if is_instance_valid(overhead_ui_thinking_instance):
		position_ui(overhead_ui_thinking_instance)
	visible = position != Vector3.ZERO
	
## Ensures ui layers are seen in correct place when appropriate 
func position_ui(ui: Control):
	var camera = get_viewport().get_camera_3d()
	
	if not camera:
		return
		
	if camera.is_position_behind(ui_anchor.global_position):
		ui.visible = false
	else:
		var screen_pos = camera.unproject_position(ui_anchor.global_position)
		ui.global_position = screen_pos - (ui.size / 2.0)
		
		
## Will have the host run the physics and customer behavior 
func _physics_process(delta: float):
	
	if is_multiplayer_authority():
		_npc_behavior(delta)
		if _is_pathfinding and _nav_agent:
			velocity = _nav_agent.get_velocity()
			move_and_slide()
		synced_position = position
			
## Customers will either:
## - search or move to targets (queue spot or table)
## - shift their position in queue
## - sit at table, eventually leaving
func _npc_behavior(delta: float):

	if _is_pathfinding:
		_update_pathfinding(delta)
		return
	
	if !_current_target:
		_pathfind_to_target()
		
	# Customers who have been seated shall wait till they have to leave
	if _seated:
		customer_state = CustomerState.THINKING
		_time_till_order = max(0, _time_till_order - delta)
		if !_time_till_order:
			_time_till_leaving = max(0, _time_till_leaving - delta)
			customer_state = CustomerState.ORDERING
			if !_time_till_leaving:
				_game_server.call_service(_table_target.id(), 
											"set_occupied", 
											[false])
				
				var exit_point = await _game_server.call_service(_food_court_id, 
											"get_exit_point", 
											[])
				_current_target = exit_point	
				_table_target = null	
				_pathfind_to_target()	
				return
				
			var plate_served = await _game_server.call_service(_table_target.id(), 
											"get_plate", 
											[])
			if plate_served:
				var food = plate_served.get_children().back()
				if food == order[1]:
					_game_server.call_service(_table_target.id(), 
												"remove_plate", 
												[])
					_time_till_leaving = 2
	
	# Customers who reach the front of the queue should begin looking for tables
	if _queued && _queue_target:
		if await _game_server.call_service(_food_court_id, 
											"is_queue_front", 
											[_queue_target.id()]):
			check_tables()
	var exit = _game_server.call_service(_food_court_id, 
											"get_exit_point", 
											[])
	if exit and _current_target == exit and !_is_pathfinding: 
		queue_free()
	
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

## Accquire spot in queue to navigate towards
func find_queue_spot() -> void:
	_queue_target = await _game_server.call_service(_food_court_id, 
													"get_free_queue_spot", 
													[_id])
	
	if _queue_target:
		_game_server.call_service(_queue_target.id(), "set_occupied", [true, _id])
		_current_target = _queue_target
		_pathfind_to_target()
		
## Shift customer to queue spot in front
func move_up_queue(spot_in_front : QueueSpot):
	if _queue_target:
		_game_server.call_service(_queue_target.id(), "set_occupied", [false])
		
	_queue_target = spot_in_front
	_game_server.call_service(_queue_target.id(), "set_occupied", [true, _id])
	_current_target = _queue_target
	_pathfind_to_target()


## Tells navigation agent where and what the target is
func _pathfind_to_target() -> void:
	if !_current_target:
		find_queue_spot()
		return
		
	_is_pathfinding = true
	var target_pos = _current_target.global_position
	if _table_target:
		target_pos += POSITION_IN_FRONT_OF_TABLE
	
	_nav_agent.target_position = target_pos

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
			_pathfind_to_target() # This forces a full recalculation
			_stuck_timer = 0.0 # Reset the timer
	else:
		# If the agent is moving freely, reset the timer.
		_stuck_timer = 0.0
	
