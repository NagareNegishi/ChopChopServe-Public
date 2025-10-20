## custom button to quit the tutorial and return to main menu
extends CustomButton

func _pressed():
    ENetManager.leave_tutorial()
    SceneManager.change_scene(SceneManager.Scene.MAIN_MENU)