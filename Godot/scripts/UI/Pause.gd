class_name Pause extends Control

#Buttons
@onready var resume_button : CustomButton = $NormalPause/ButtonsContainer/ResumeButton
@onready var recipes_button : CustomButton = $NormalPause/ButtonsContainer/Recipes
@onready var quit_button : CustomButton = $NormalPause/ButtonsContainer/Quit

@onready var recipe_ui : Control = $Recipes
@onready var host_ui : Control = $HostPause
@onready var normal_ui : Control = $NormalPause

func _ready() -> void:
	resume_button.pressed.connect(_resume)
	recipes_button.pressed.connect(_recipes)
	quit_button.pressed.connect(_quit)
	recipe_ui.visible = false

func _quit():
	get_tree().paused = false
	if ENetManager.is_host():
		ENetManager._reset_game()
	else:
		rpc("_disconnect_player", ENetManager.get_my_id()) 

@rpc("any_peer", "call_local")
func _disconnect_player(id : int):
	if ENetManager.is_host():
		ENetManager.player_leaves_intentionally(id)



func _resume():
	toggle_visible(false)
	
	
func _customize():
	pass


func _recipes():
	normal_ui.visible = false
	host_ui.visible = false
	recipe_ui.visible = true


func toggle_visible(tog : bool):
	visible = tog
	
	
	if ENetManager.is_host():
		rpc("host_pause", tog)
	else: 
		if GlobalScript.get_local_player(): GlobalScript.get_local_player().disable_controls(tog, true)

@rpc("any_peer", "call_local")
func host_pause(tog : bool):
	visible = tog
	normal_ui.visible = !tog if !ENetManager.is_host() else tog
	host_ui.visible = tog if !ENetManager.is_host() else !tog
	get_tree().paused = tog
	
