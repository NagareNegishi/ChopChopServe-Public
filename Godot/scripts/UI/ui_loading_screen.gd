class_name LoadingScreen
extends Control

var hints : Array[String] = ["No frogs were harmed in development",
							"Watch out for wild rats!",
							"Fire is pretty scary",
							"Killer Tomatos about",
							"Can you do the infamous back dash?",
							"We love CoPo",
							"You can check recipes at any time in the pause menu"]

@onready var hint_timer : Timer = Timer.new()
@onready var test_timer : Timer = Timer.new()
@onready var fadeout_timer : Timer = Timer.new()

@onready var hint_text : RichTextLabel = $HintText
@onready var load_anim_player : AnimationPlayer = $ChefHatEffect/AnimationPlayer
@onready var floor_anim_player : AnimationPlayer = $Floor/AnimationPlayer
@onready var froggo_anim_player : AnimationPlayer = $Clip/Froggo/AnimationPlayer
@onready var froggo : TextureRect = $Clip/Froggo


## Called when the node enters the scene tree for the first time.
## @return void
func _ready() -> void:
	#Hides noees at start
	hint_text.visible = false
	hint_text.text = ""
	froggo.modulate = Color(255,2555,255,0)
	
	#Adds timers to the scene tree
	add_child(hint_timer)
	add_child(test_timer)
	add_child(fadeout_timer)
	self.set_as_top_level(true)
	#Sets the wait times for timers
	hint_timer.wait_time = 0.05
	fadeout_timer.wait_time = 1.5
	test_timer.wait_time = 7
	
	#Connecting all signals
	load_anim_player.animation_finished.connect(_animation_finshed)
	hint_timer.timeout.connect(_show_hint)
	test_timer.timeout.connect(remove)
	fadeout_timer.timeout.connect(_show_screen)



## Removes the UI from screen
## @return void
func remove() -> void:
	hint_text.visible = false
	load_anim_player.play("FroggoFadeIn",-1, -2, true)
	floor_anim_player.play("ScaleIn", -1, -2, true)
	fadeout_timer.start()
	test_timer.stop()

func play():
	load_anim_player.play("LoadIn", -1, 4.5)
	test_timer.start()



## Shows hint message on screen and starts playing the froggo animation
## @return void
func _show_hint() -> void:
	hint_timer.stop()
	if hints.size() <= 0 : return
	
	hint_text.text = hints.pick_random()
	hint_text.visible = true
	floor_anim_player.play("ScaleIn", -1, 2)
	froggo_anim_player.play("Walk")

## Called when the inital chef hat effect is done
## @return void
func _animation_finshed(anim_name : String):
	if anim_name == "LoadIn":
		print("finshed")
		load_anim_player.animation_finished.disconnect(_animation_finshed)
		load_anim_player.play("FroggoFadeIn",-1)
		hint_timer.start()

## Called when the final chef hat effect is coming from screen
## @return void
func _show_screen():
	load_anim_player.play("LoadIn", -1, -1.4, true)
	fadeout_timer.stop()
