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


func _setup_node(node : TutorialNode):
	assert(node)
	tutorial_widget.set_text(node.text)

	match node.type:
		TutorialNode.TYPE.WAIT:

			await get_tree().create_timer(node.time).timeout

			_update_progress()

		TutorialNode.TYPE.SIGNAL:
			timer.start()
			GlobalScript.tutorial_step.connect(_signal_out)


func _signal_out(num : int):
	if num != current.num: return

	if !timer.is_stopped():
		await timer.timeout

	GlobalScript.tutorial_step.disconnect(_signal_out)
	_update_progress()
