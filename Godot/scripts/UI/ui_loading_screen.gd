class_name LoadingScreen
extends Control

var hints : Array[String] = ["You can throw items with [image]"]

@onready var hint_timer : Timer = Timer.new()
@onready var test_timer : Timer = Timer.new()
@onready var hint_text : RichTextLabel = $HintText
@onready var load_anim_player : AnimationPlayer = $ColorRect/AnimationPlayer
@onready var progress_bar : TextureProgressBar = $ProgressBar
@onready var texture_rect : TextureRect = $TextureRect

func _ready() -> void:
	progress_bar.visible = false
	texture_rect.visible = false
	hint_text.visible = false
	
	add_child(hint_timer)
	add_child(test_timer)
	hint_timer.wait_time = 0.05
	hint_timer.timeout.connect(_show_hint)
	hint_text.text = ""
	
	load_anim_player.animation_finished.connect(animation_finshed)
	load_anim_player.play("LoadIn", -1, 4.5)
	
	test_timer.wait_time = 3
	test_timer.timeout.connect(remove)
	test_timer.start()
	


func remove() -> void:
	hint_text.visible = false
	load_anim_player.play("LoadIn", -1, -2, true)


func _show_hint() -> void:
	hint_timer.stop()
	if hints.size() <= 0 : return
	
	hint_text.text = hints.pick_random()
	hint_text.visible = true
	

func animation_finshed(anim_name : String):
	if anim_name == "LoadIn":
		print("finshed")
		load_anim_player.animation_finished.disconnect(animation_finshed)
		hint_timer.start()
