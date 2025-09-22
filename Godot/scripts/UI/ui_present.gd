class_name UIPresent
extends Control

@onready var progress_bar : TextureProgressBar = $TextureProgressBar

func set_colour(teamID : int):
	pass
	
func add_progress(add_amount : float):
	progress_bar.value += add_amount
	progress_bar.value = clamp(progress_bar.value, 0, 1)
	
