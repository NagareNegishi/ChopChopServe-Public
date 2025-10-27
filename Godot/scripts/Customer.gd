class_name Customer extends NPC

enum CustomerState { IDLE, THINKING, ORDERING }

# Agents with velocity below this are considered stuck.
const AGENT_STUCK_THRESHOLD: float = 0.15

# Maximum time in seconds a customer will "think" before placing an order.
const MAXIMUM_ORDER_THINK_TIME: float = 1.0
# Time in seconds the agent must be stuck before recalculating its path.
const STUCK_RECALCULATE_TIME: float = 1.0 
# Time in seconds the customer will stay seated till they get fed up not being served
const MAXIMUM_SEATING_TIME: float = 60
# Time in seconds the customer will stop moving for after falling
const FALLEN_OVER_TIME = 5.0

# A localoffset from a table's origin to define where the customer sits
@export var POSITION_IN_FRONT_OF_TABLE: Vector3 = Vector3(0, 0.25, 0.5)

# customers will fall over due to water spills
@export var fallen_over : bool
@export var _seated = false
@export var synced_position: Vector3
@export var synced_velocity: Vector3
@export var overhead_ui_order: PackedScene # Shows meal customer wants
@export var overhead_ui_thinking: PackedScene # Shows frog thinking
# Allows for orders to be randomly selected
@export var order_gen_meal_number = randi()
@export var order_gen_type_number = randi()
@export var _time_till_leaving: float = MAXIMUM_SEATING_TIME
@export var is_tweening_to_seat = false # true when customer first arrives to table

@export var customer_state: CustomerState = CustomerState.IDLE:
	# Runs on all clients when the state changes.
	set(new_state):
		if customer_state == new_state:
			return
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
														[order_gen_meal_number, 
														order_gen_type_number])
				overhead_ui_order_instance.set_order(order[0])
				#print("\n\n\nTHIS IS THE ORDER FROM THE CUSTOMER:::::   ", order)

@onready var ui_anchor: Marker3D = $OverheadUIAnchor
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

var fallen_over_timer = FALLEN_OVER_TIME
var _table_target: Node3D = null
var _queue_target: Node3D = null
var _queued = false
var _food_court_id
var _restaurant_number: int
var order: Array
var _time_till_order: float = MAXIMUM_ORDER_THINK_TIME
var _stuck_timer: float = 0.0
var _id
var overhead_ui_order_instance: UIOrder
var overhead_ui_thinking_instance: UIThinking
var is_critic: bool = false
var critic_rep_amount : float = 50
var critic_victim_team : int = -1
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
	add_to_group("Customer")
	var ui_layer = get_tree().get_first_node_in_group("Canvas")
	# Create and add UI elements to scene 
	if ui_layer:
		overhead_ui_order_instance = overhead_ui_order.instantiate()
		overhead_ui_thinking_instance = overhead_ui_thinking.instantiate()
		
		for ui_element in [overhead_ui_order_instance, 
		overhead_ui_thinking_instance]:
			ui_element.scale = Vector2.ONE * 0.3
			ui_element.hide()
			ui_layer.add_child(ui_element)
		
	if not is_multiplayer_authority():
		set_physics_process(false) # physics calculated server side
	else:
		_initialize()

## Syncing position of customer and overhead ui positions 
func _process(_delta):
	
	if is_instance_valid(animation_tree): # Setting animation booleans
		animation_tree.set("parameters/conditions/is_moving", synced_velocity.length() > 0.1)
		animation_tree.set("parameters/conditions/not_moving", synced_velocity.length() < 0.1 && _seated == null)
		animation_tree.set("parameters/conditions/is_sitting", _seated)
		animation_tree.set("parameters/conditions/is_tweening_to_seat", is_tweening_to_seat)
		animation_tree.set("parameters/conditions/state", customer_state) 
		
	if not is_multiplayer_authority(): # Passing server customer pos to clients
		position = synced_position
	
	
	# Managing Overhead UIs
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
		if fallen_over:
			fallen_over_timer -= delta
			if fallen_over_timer < 0:
				fallen_over = false
			return
		synced_velocity = velocity
		_npc_behavior(delta)
		if _is_pathfinding and _nav_agent:
			velocity = _nav_agent.get_velocity()
			move_and_slide()
			_rotate_npc(delta)
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
		# Check the current state and act accordingly
		if customer_state == CustomerState.IDLE:
			# If the customer just sat down, start the thinking process.
			# This transition will only happen once.
			customer_state = CustomerState.THINKING
		
		elif customer_state == CustomerState.THINKING:
			# Only run the thinking timer if in this state
			_time_till_order = max(0, _time_till_order - delta)
			if !_time_till_order:
				# Timer is up, transition to ordering.
				# This transition will only happen once.
				customer_state = CustomerState.ORDERING
		
		elif customer_state == CustomerState.ORDERING:
			
			# Only run the leaving timer if in this state
			_time_till_leaving = max(0, _time_till_leaving - delta)
			if !_time_till_leaving:
				# Timer is up, customer leaves.
				
				_game_server.call_service(_table_target.id(), "set_occupied", [false])
				if is_critic: # not serving critic giving will lose rep
					ReputationSystem.minus_reputation(critic_victim_team, 
															critic_rep_amount)
				else:
					ReputationSystem.minus_reputation(1, 5)
					ReputationSystem.minus_reputation(2, 5)
				var exit_point = await _game_server.call_service(_food_court_id, "get_exit_point", [])
				_current_target = exit_point	
				_table_target = null	
				_pathfind_to_target()	
				return # Important to return here
				
			var plate_served = await _game_server.call_service(_table_target.id(), "get_plate", [])
			if plate_served:
				var food = plate_served.get_children().back()
				if (food is MenuItem and food.get_meal_name() == order[0].get_meal_name()):
					CurrencySystem.server_add_currency(plate_served.last_held_by_team, food.cost)
					ReputationSystem.server_add_reputation(1 if plate_served.last_held_by_team == 2 else 2,
															1.75 * max(5, GameState.current_day))
					ReputationSystem.server_add_reputation(plate_served.last_held_by_team, 
															-2.2 * GameState.current_day)
					_table_target.rpc("remove_plate")
					_table_target.remove_plate()
					_time_till_leaving = 2
					
	# Customers who reach the front of the queue should begin looking for tables
	if _queued and _queue_target:
		if await _game_server.call_service(_food_court_id, "is_queue_front", [_queue_target.id()]):
			check_tables()
	var exit = _game_server.call_service(_food_court_id, "get_exit_point", [])
	if exit and _current_target == exit and !_is_pathfinding:
		rpc("despawn")
	
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
		
		if _table_target:
			is_tweening_to_seat = true
			var target_position = _nav_agent.target_position + POSITION_IN_FRONT_OF_TABLE
			
			var look_at_point = _table_target.global_position
			look_at_point.y = target_position.y
			# future transform of where customer tweens to
			var future_transform = Transform3D(Basis(), target_position)
			var final_transform = future_transform.looking_at(look_at_point, Vector3.UP)
			var target_rotation_y = final_transform.basis.get_euler().y - PI
			
			var tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_CUBIC)
			
			tween.parallel().tween_property(self, "global_position", target_position, 0.5)
			tween.parallel().tween_property(self, "rotation:y", target_rotation_y, 0.5)
			tween.finished.connect(func(): is_tweening_to_seat = false)
			
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
	
@rpc("any_peer", "call_local")
func despawn():
	queue_free()

	if is_instance_valid(overhead_ui_thinking_instance):
		overhead_ui_order_instance.queue_free()
	if is_instance_valid(overhead_ui_order_instance):
		overhead_ui_order_instance.queue_free()

## For waterspill sabotage
func fall_down():
	if is_multiplayer_authority():
		fallen_over = true
		fallen_over_timer = FALLEN_OVER_TIME
