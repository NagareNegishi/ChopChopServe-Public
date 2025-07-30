class_name InteractableComponent extends Area3D

signal interacted()
signal hovered(is_hovered : bool)
signal action_use(is_action : bool)

var can_be_interacted : bool = true

## Emits signal that this component has been interacted with
## @return void
func interact() -> void:
	if can_be_interacted:
		emit_signal("interacted")


## Emits signal that the player has used action with this object
## @return void
func action(in_use : bool) -> void:
	emit_signal("action_use", in_use)


## Emits signal that the player is hovering over this object
## @return void
func hover(hovering : bool) -> void:
	if can_be_interacted:
		emit_signal("hovered", hovering)
