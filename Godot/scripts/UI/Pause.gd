class_name Pause extends Control

#Buttons
@onready var resume_button : CustomButton = $NormalPause/ButtonsContainer/ResumeButton
@onready var customize_button : CustomButton = $NormalPause/ButtonsContainer/CustomizeButton
@onready var recipes_button : CustomButton = $NormalPause/ButtonsContainer/Recipes
@onready var quit_button : CustomButton = $NormalPause/ButtonsContainer/Quit


func _ready() -> void:
	resume_button.pressed.connect(_resume)
	customize_button.pressed.connect(_customize)
	recipes_button.pressed.connect(_recipes)
	quit_button.pressed.connect(_quit)


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
	pass


func toggle_visible(tog : bool):
	visible = tog
	
	
	if ENetManager.is_host():
		rpc("host_pause", tog)
	else: 
		GlobalScript.get_local_player().disable_controls(tog)

@rpc("any_peer", "call_local")
func host_pause(tog : bool):
	visible = tog
	$NormalPause.visible = !tog if !ENetManager.is_host() else tog
	$HostPause.visible = tog if !ENetManager.is_host() else !tog
	get_tree().paused = tog
	
