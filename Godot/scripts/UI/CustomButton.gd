class_name CustomButton
extends Button

@export var normal_size := Vector2(0.6,0.6)
@export var hover_size := Vector2(0.7,0.7)

var tween : Tween


func _ready() -> void:
	self.mouse_entered.connect(_hovered)
	self.mouse_exited.connect(_unhovered)
	
	await get_tree().process_frame
	
	self.scale = normal_size
	self.pivot_offset = self.size/2
	get_tree().root.size_changed.connect(_on_window_resized)
	
	
func _hovered() -> void:
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(
		self, "scale", hover_size, 0.1
	)


func _unhovered() -> void:
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(
		self, "scale", normal_size, 0.1
	)


func _on_window_resized():
	self.scale = normal_size
	self.pivot_offset = self.size/2
