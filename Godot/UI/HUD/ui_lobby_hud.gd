class_name HUBHud extends Control

signal tutorial_complete 
@export var code_label : Label
@export var tutorial_widget : TutorialWidget
@export var tutorial_steps : Array[TutorialNode]
@export var timer : Timer
var current : TutorialNode
var progress : int = 0


func _ready() -> void:
	code_label.text = ENetManager.enet_layer.get_connection_info().replace(":7000","")
	tutorial_widget.set_progress_max(tutorial_steps.size())
	


func set_tutorial_vis(vis : bool):
	tutorial_widget.visible = vis
	if vis: 
		_setup_node(tutorial_steps[0])
		return
	reset()


func set_tutorial_text(text : String):
	tutorial_widget.set_text(text)


func _update_progress():
	timer.stop()
	progress += 1
	
	if progress >= tutorial_steps.size(): 
		tutorial_complete.emit()
		reset()
		return

	tutorial_widget.set_progress(progress)
	current = tutorial_steps[progress]
	_setup_node(current)


func reset():
	progress = 0
	current = tutorial_steps[0]
	tutorial_widget.set_progress(0)
	GlobalScript.tutorial_counter_tomato = 0


func _setup_node(node : TutorialNode):
	assert(node)
	var text = node.text_keyboard if Input.get_connected_joypads().size() <= 0 \
	else node.text_controller
	tutorial_widget.set_text(text)

	match node.type:
		TutorialNode.TYPE.WAIT:

			await get_tree().create_timer(node.time).timeout

			_update_progress()

		TutorialNode.TYPE.SIGNAL:
			timer.wait_time = node.time
			GlobalScript.tutorial_step.connect(_signal_out)


func _signal_out(num : int):
	if num != current.num: return
	
	GlobalScript.tutorial_step.disconnect(_signal_out)
	
	timer.start()
	timer.timeout.connect(_update_progress)
