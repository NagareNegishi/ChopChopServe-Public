class_name HUBHud extends Control

@export var code_label : Label
@export var tutorial_widget : TutorialWidget

func _ready() -> void:
	code_label.text = ENetManager.enet_layer.get_connection_info().replace(":7000","")

func set_tutorial_vis(vis : bool):
	tutorial_widget.visible = vis

func set_tutorial_text(text : String):
	tutorial_widget.set_text(text)

func _update_progress():
	pass
