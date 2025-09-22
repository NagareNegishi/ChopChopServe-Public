extends Area3D

@export var duration: float = 10.0
@export var slow_down: float = 0.5
		
@onready var reputation_system = ReputationSystem
var sabotaged_teamID: int

signal in_water_spill()
signal customer_down()

func _ready() -> void:
	# Connect to body entered signal
	body_entered.connect(_on_body_entered)

# Set which team is being sabotaged
func set_sabotaged_team(teamID: int) -> void:
	print("Water spill sabotaging team: ", teamID)
	sabotaged_teamID = teamID

func start_timer(seconds: float) -> void:
	var timer = Timer.new()
	timer.wait_time = seconds
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	queue_free()

# Handle customer fall on server only to avoid duplicate effects
@rpc("any_peer", "call_remote", "reliable") 
func handle_customer_fall(customer_path: NodePath) -> void:
	if not multiplayer.is_server():
		return
		
	var customer = get_node_or_null(customer_path)
	if not customer:
		return
		
	# 10% chance of falling
	var chance = randi() % 100
	print("Customer fall chance: ", chance)
	
	if chance < 10:  # 10% chance
		print("Customer should fall")
		reputation_system.minus_reputation(sabotaged_teamID, 5)
		# Notify all clients about the fall
		customer_falls.rpc(customer_path)

# Notify all clients that customer fell
@rpc("authority", "call_local", "reliable")
func customer_falls(customer_path: NodePath) -> void:
	var customer = get_node_or_null(customer_path)
	if customer:
		# Add customer fall animation/effect here
		print("Customer fell: ", customer)
		emit_signal("customer_down")

func _on_body_entered(body: Node3D) -> void:
	print("Body entered water spill: ", body.name)
	
	if body is Player:
		# Player effects happen locally on each client
		body.drop_item(false)
		reputation_system.minus_reputation(body.get_team(), 5)
		print("Player dashed in water and dropped items: ", body)
		emit_signal("in_water_spill")
		
	elif body is Customer:
		print("Customer in water: ", body)
		# Only handle customer fall on server to avoid duplicates
		if multiplayer.is_server():
			var customer_path = body.get_path()
			handle_customer_fall.rpc(customer_path)
		
	else:
		print("Unknown body entered water: ", body)