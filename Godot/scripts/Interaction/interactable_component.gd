class_name InteractableComponent extends Area3D

var overlay = preload("res://materials/InteractOverlay.tres")

signal interacted()
signal hovered(is_hovered : bool)
signal action_use(is_action : bool)
signal local_action_use(is_action : bool)
signal toggle_collision(turn_on : bool)

@onready var tween : Tween = get_tree().create_tween()
@export var is_pickup : bool
@export var has_action : bool = false

var can_be_interacted : bool = true

@onready var parent = get_parent()
@onready var start_pos = 1
@onready var end_pos = start_pos + 0.2

func _ready() -> void:
	tween.stop()
	set_physics_process(false)


## Emits signal that this component has been interacted with
## @return void
func interact() -> void:
	if can_be_interacted:
		emit_signal("interacted")


## Emits signal that the player has used action with this object
## @return void
func action(in_use : bool) -> void:
	if has_action:
		emit_signal("local_action_use", in_use)
		rpc("_client_action", in_use)
		

@rpc("any_peer", "call_local")
func _client_action(in_use : bool):
	emit_signal("action_use", in_use)


## Emits signal that the player is hovering over this object
## @return void
func hover(hovering : bool) -> void:
	if !can_be_interacted: return
	
	for child in get_parent().get_children():
		if child is MeshInstance3D: child.material_overlay = overlay if hovering else null
			
		if !child.scene_file_path.ends_with(".glb"): continue
		
		for c in child.get_children(true):
			if c is MeshInstance3D: c.material_overlay = overlay if hovering else null

	
	emit_signal("hovered", hovering)


## Allows to turn on & off the collision box for interaction events
## @param turn_on boolean the sets the collsion on or off
## @return void
func turn_on_collision(turn_on: bool) -> void:
	emit_signal("toggle_collision", turn_on)


func custom_rotate(play : bool):
	_server_rotate.rpc(play)


@rpc("any_peer", "call_local")
func _server_rotate(play : bool):
	set_physics_process(play)
	_bobble(play)
	get_parent().collision_layer = 0 if play else 1


func _bobble(play : bool):
	if !play: 
		tween.stop()
		return
	
	tween.tween_property(get_parent(), "position", 
		 Vector3(parent.position.x, end_pos, parent.position.z), 1.5) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(get_parent(), "position",  
		 Vector3(parent.position.x, start_pos, parent.position.z), 1.5) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	tween.set_loops()


func _physics_process(delta: float) -> void:
	parent.rotation.y +=  1.5 * delta
