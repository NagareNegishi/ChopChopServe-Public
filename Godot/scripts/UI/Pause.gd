class_name Pause extends Control

#Buttons
@onready var resume_button : CustomButton = $ButtonsContainer/ResumeButton
@onready var customize_button : CustomButton = $ButtonsContainer/CustomizeButton
@onready var recipes_button : CustomButton = $ButtonsContainer/Recipes
@onready var quit_button : CustomButton = $ButtonsContainer/Quit


func _ready() -> void:
	resume_button.pressed.connect(_resume)
	customize_button.pressed.connect(_customize)
	recipes_button.pressed.connect(_recipes)
	quit_button.pressed.connect(_quit)


func _quit():
	get_tree().paused = false
	if ENetManager.is_host():
		ENetManager.player_leaves_intentionally(ENetManager.get_my_id())
	else:
		ENetManager.enet_layer.send_to(1, {
			"type": "player_leaving_intentionally",
			"player_id": ENetManager.get_my_id()
		})
		await get_tree().create_timer(0.1).timeout 





func _resume():
	toggle_visible(false)
	
	
func _customize():
	pass


func _recipes():
	pass


func toggle_visible(tog : bool):
	visible = tog
	get_tree().paused = tog
