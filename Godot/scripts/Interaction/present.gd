extends AbstractThrowable

@onready var interact_timer : Timer = Timer.new()
@onready var interact_component : InteractableComponent = $InteractableComponent
@onready var details_ui : UIPresent = $Price/SubViewport/UiPresent

func _ready() -> void:
	interact_component.action_use.connect(_on_interactable_component_action_use)
	add_child(interact_timer)
	interact_timer.wait_time = 0.01
	interact_timer.autostart = false
	interact_timer.timeout.connect(_timeout)

func _on_interactable_component_action_use(is_action: bool) -> void:
	if is_action:
		interact_timer.start()
	else:
		interact_timer.stop()

func _timeout():
	pass
