class_name QuestionMark extends StaticBody3D

signal tutorial(on : bool)

@export var interact_comp : InteractableComponent
@export var sprite : Sprite3D
@export var label : Label
@export var hud : HUBHud

var current_on : bool
func _ready() -> void:
	sprite.visible = false
	interact_comp.interacted.connect(interact)
	interact_comp.hovered.connect(hover)
	interact_comp.custom_rotate(true)
	hud.tutorial_complete.connect(_tutorial_complete)


func interact():
	start_tutorial(!current_on)


func start_tutorial(on : bool):
	tutorial.emit(on)
	label.text = "Start Tutorial" if !on else "Stop Tutorial"
	current_on = on


func hover(is_hover : bool):
	sprite.visible = is_hover if !current_on else true


func _tutorial_complete():
	start_tutorial(false)
