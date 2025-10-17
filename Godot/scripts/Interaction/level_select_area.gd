extends Area3D

@export var level : SceneManager.Scene
@export var car : PlayerCar

func _ready() -> void:
	area_entered.connect(_area_entered)

func _area_entered(area : Area3D):
	if !ENetManager.is_host() : return
	
	car.disable_input(true)
	await get_tree().create_timer(1).timeout
	
	UIManager.play_load()
	rpc("_play_load")
	
	await get_tree().create_timer(3.5).timeout
	SceneManager.change_scene_all_players(level)

@rpc("any_peer", "call_local")
func _play_load():
	get_tree().current_scene.get_node("== HUD ==/HUD").visible = false
	get_tree().current_scene.get_node("== HUD ==/UiPause").visible = false
