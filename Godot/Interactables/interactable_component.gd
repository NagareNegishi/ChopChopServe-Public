class_name InteractableComponent extends Area3D

signal interacted()
signal hovered(is_hovered : bool)
signal action_use(is_action : bool)

var can_be_interacted : bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func interact():
	#print("Component: Interacted")
	if can_be_interacted:
		emit_signal("interacted")

func action(in_use : bool):
	emit_signal("action_use", in_use)


func hover(hovering : bool) -> void:
	if can_be_interacted:
		emit_signal("hovered", hovering)
