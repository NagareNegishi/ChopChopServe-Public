## Simple popup for network messages
extends PanelContainer
class_name NetworkPopup

@onready var label: Label = $MarginContainer/Label
@onready var timer: Timer = $Timer


## Setup the popup with message and duration
## @param message: The message to display
## @param duration: How long to display before fading out
func setup(message: String, duration: float = 3.0):
	label.text = message
	timer.wait_time = duration
	timer.timeout.connect(_on_timeout)
	timer.start()
	# Fade in
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)


## Fade out and free itself
func _on_timeout():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.finished.connect(queue_free)
