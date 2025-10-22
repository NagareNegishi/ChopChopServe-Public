class_name CustomButton
extends Button

@export var normal_size := Vector2(1,1)
@export var hover_size := Vector2(1.1, 1.1)


var tween : Tween


func _ready() -> void:
	self.mouse_entered.connect(_hovered)
	self.mouse_exited.connect(_unhovered)
	pivot_offset = size/2 + Vector2(0, -50)

func _hovered() -> void:
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(
		self, "scale", hover_size, 0.1
	)
	pass


func _unhovered() -> void:
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(
		self, "scale", normal_size, 0.1
	)
	pass
