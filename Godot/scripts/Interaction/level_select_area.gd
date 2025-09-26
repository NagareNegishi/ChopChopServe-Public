extends Area3D

@export var level : SceneManager.Scene
@export var load_ui : LoadingScreen
@export var car : PlayerCar

func _ready() -> void:
	area_entered.connect(_area_entered)

func _area_entered(area : Area3D):
	if !ENetManager.is_host() : return
	car.disable_input(true)
	get_tree().current_scene.get_node("== HUD ==/HUD").visible = false
	await get_tree().create_timer(1).timeout
	
	rpc("_play_load")
	
	await get_tree().create_timer(10).timeout
	
	SceneManager.change_scene_all_players(level)

@rpc("any_peer", "call_local")
func _play_load():
	get_tree().current_scene.get_node("== HUD ==/UiPause").visible = false
	load_ui.visible = true
	load_ui.play()
	
