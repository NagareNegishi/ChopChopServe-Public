class_name InteractableComponent extends Area3D

signal interacted()
signal hovered(is_hovered : bool)
signal action_use(is_action : bool)
signal toggle_collision(turn_on : bool)

@export var is_pickup : bool
@export var has_action : bool = false

var can_be_interacted : bool = true


## Emits signal that this component has been interacted with
## @return void
func interact() -> void:
	if can_be_interacted:
		emit_signal("interacted")


## Emits signal that the player has used action with this object
## @return void
func action(in_use : bool) -> void:
	if has_action:
		rpc("_client_action", in_use)
		

@rpc("any_peer", "call_local")
func _client_action(in_use : bool):
	emit_signal("action_use", in_use)


## Emits signal that the player is hovering over this object
## @return void
func hover(hovering : bool) -> void:
	if can_be_interacted:
		emit_signal("hovered", hovering)


## Allows to turn on & off the collision box for interaction events
## @param turn_on boolean the sets the collsion on or off
## @return void
func turn_on_collision(turn_on: bool) -> void:
	emit_signal("toggle_collision", turn_on)
