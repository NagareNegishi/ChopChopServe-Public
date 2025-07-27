class_name InteractableComponent extends Area3D

signal interacted()
signal hovered(is_hovered : bool)

var can_be_interacted : bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func interact():
	print("Component: Interacted")
	emit_signal("interacted")


func hover(hovering : bool) -> void:
	emit_signal("hovered", hovering)
