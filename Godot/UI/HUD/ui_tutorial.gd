class_name TutorialWidget extends Control

@export var label : Label
@export var progress : ProgressBar

func set_text(text : String):
	label.text = text

func set_progress(num : int):
	progress.value = num

func set_progress_max(num : int):
	progress.max_value = num
