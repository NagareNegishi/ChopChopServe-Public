class_name Pause extends Control

#Buttons
@onready var resume_button : CustomButton = $NormalPause/ButtonsContainer/ResumeButton
@onready var quit_button : CustomButton = $NormalPause/ButtonsContainer/Quit
@onready var multiplayter : CustomButton = $NormalPause/ButtonsContainer/Multiplayer

@onready var host_ui : Control = $HostPause
@onready var normal_ui : Control = $NormalPause

var can_unpause_controller : bool
func _ready() -> void:
	resume_button.pressed.connect(_resume)
	quit_button.pressed.connect(_quit)
	resume_button.custom_focus.connect(_focus_changed)
	quit_button.custom_focus.connect(_focus_changed)
	multiplayter.custom_focus.connect(_focus_changed)
	Input.joy_connection_changed.connect(_controller)
	_controller(0, Input.get_connected_joypads().size() >= 1)
var current_focus : Button

func _controller(device : int, connected : bool):
	if !connected && current_focus != null: 
		current_focus.release_focus()
		current_focus = null
	resume_button.grab_focus()
	current_focus = resume_button


func _focus_changed(button : CustomButton):
	current_focus = button


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


func toggle_visible(tog : bool):
	visible = tog
	UIManager.canvas_layer.visible = tog
	if tog: 
		get_tree().create_timer(0.2).timeout.connect(cont)
		_controller(0, Input.get_connected_joypads().size() >= 1)
	
	if ENetManager.is_host():
		rpc("host_pause", tog)
	else: 
		if GlobalScript.get_local_player(): GlobalScript.get_local_player().disable_controls(tog, true)

func cont():
	can_unpause_controller = true

@rpc("any_peer", "call_local")
func host_pause(tog : bool):
	visible = tog
	UIManager.canvas_layer.visible = tog
	normal_ui.visible = !tog if !ENetManager.is_host() else tog
	host_ui.visible = tog if !ENetManager.is_host() else !tog
	get_tree().paused = tog

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause") && resume_button.visible and can_unpause_controller: 
		can_unpause_controller = false
		_resume()
	if Input.is_action_just_pressed("Interact") and Input.get_connected_joypads().size() >= 1 && current_focus != null && visible:
		current_focus.pressed.emit()
		can_unpause_controller = false
