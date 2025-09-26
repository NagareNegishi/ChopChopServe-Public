## Auto loaded as: SceneManager
## scene_manager.gd (autoload)
extends Node


signal scene_ready() # Host only

enum Scene {
	MAIN_MENU,
	LOBBY,
	# Add more stage here
	Food_Court,
	# remove later
	SETTINGS,
	LOBBY_TEST,
	TEST,
	JOHNO_TEST,
	JESS_TEST,
	EMMA_TEST
}

const SCENE_PATHS = {
	Scene.MAIN_MENU: "res://LevelDesign/main_menu_enviro.tscn",
	Scene.LOBBY: "res://LevelDesign/Levelselectworld.tscn", # Will be added later
	Scene.Food_Court: "res://Milestone3Submission.tscn",
	Scene.SETTINGS: "", # Will be added later
	Scene.LOBBY_TEST: "res://scenes/Network_Layer/lobby_network.tscn",
	Scene.TEST: "res://scenes/Appliance_system/Appliance_test.tscn",
	Scene.JOHNO_TEST: "res://JohnoTestLevel3.tscn",
	Scene.JESS_TEST: "res://JessTestScene6.tscn",
	Scene.EMMA_TEST: "res://scripts/Food/testingSceneEmma2.tscn"
}

var current_scene: Scene = Scene.MAIN_MENU
var is_changing: bool = false

# Host only
var players_in_scene: Dictionary = {}  # player_id -> scene_enum
var waiting: bool = false


## Setup
func _ready():
	ENetManager.game_reset.connect(_on_game_reset)
	ENetManager.disconnected_from_server.connect(_back_to_main_menu)


## Change Scene
## @param scene: The target scene enum
func change_scene(scene: Scene) -> void:
	if is_changing:
		print("Scene change already in progress")
		return
	if scene not in SCENE_PATHS:
		push_error("Scene not found: " + str(scene))
		return
	var scene_path = SCENE_PATHS[scene]
	if scene_path == "":
		push_error("Scene path not implemented yet: " + str(scene))
		return
	is_changing = true
	var old_scene = current_scene
	current_scene = scene
	print("Changing from %s to %s" % [Scene.keys()[old_scene], Scene.keys()[scene]])
	get_tree().call_deferred("change_scene_to_file", scene_path)
	await get_tree().tree_changed
	is_changing = false
	if ENetManager.is_host():
		players_in_scene[ENetManager.get_my_id()] = scene
		waiting = true
		# Check if clients are already in the scene
		if _is_players_ready():
			print("All players ready in scene: %s" % Scene.keys()[current_scene])
			waiting = false
			scene_ready.emit()
	else:
		_report_scene_ready.rpc_id(1, ENetManager.get_my_id(), scene)


## Remote command to change scene, called by host
## @param scene: The target scene enum
@rpc("authority", "call_remote", "reliable")
func _command_change_scene(scene: Scene):
	if current_scene == scene: # Ignore if already in the requested scene
		return
	change_scene(scene)


## Client reports to host, Host checks if all players are ready
## @param player_id: The ID of the reporting player
## @param scene: The scene enum the player is currently in
@rpc("any_peer", "call_remote", "reliable")
func _report_scene_ready(player_id: int, scene: int) -> void:
	if not ENetManager.is_host():
		return
	players_in_scene[player_id] = scene as Scene
	if _is_players_ready():
		print("All players ready in scene: %s" % Scene.keys()[current_scene])
		waiting = false
		scene_ready.emit()


## Check if all players are in the current scene, Host only
## @return: true if all players are in the current scene
func _is_players_ready() -> bool:
	if not waiting:
		return false
	var expected =  ENetManager.get_player_list()
	for player_id in expected:
		if player_id not in players_in_scene: # Missing player
			return false
		if players_in_scene[player_id] != current_scene: # Player not in the current scene
			_command_change_scene.rpc_id(player_id, current_scene)
			return false
	return true


## Host initiates scene change for all players
## @param scene: The target scene enum
func change_scene_all_players(scene: Scene) -> void:
	if not ENetManager.is_host():
		push_warning("change_scene_all_players() should only be called by host")
		return
	waiting = true
	players_in_scene.clear()
	_command_change_scene.rpc(scene)
	change_scene(scene)


## Handle game reset, Host only
func _on_game_reset():
	if ENetManager.is_host():
		change_scene_all_players(Scene.LOBBY_TEST)


## Back to Main Menu
func _back_to_main_menu() -> void:
	change_scene(Scene.MAIN_MENU)
