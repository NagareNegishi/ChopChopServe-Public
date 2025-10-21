class_name QuestionMark extends StaticBody3D

@export var interact_comp : InteractableComponent

func _ready() -> void:
	interact_comp.interacted.connect(interact)
	interact_comp.rotate_drop()

func interact():
	UIManager.play_load()
	
	await get_tree().create_timer(3.5).timeout
	
	SceneManager.change_scene_all_players(SceneManager.Scene.TUTORIAL)
