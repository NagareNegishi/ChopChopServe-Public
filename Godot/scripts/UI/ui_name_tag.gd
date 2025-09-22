class_name NameTag extends Control

@onready var tag : Label = $HBoxContainer/Label

func set_tag(new_name : String):
	tag.text = new_name
