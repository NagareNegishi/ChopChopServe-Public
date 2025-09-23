class_name NameTag extends Control

@onready var tag : Label = $HBoxContainer/Label


func set_color(player_id : int):
	var team : int = ENetManager.get_team(player_id)
	var color : Color = Color("fff6ae") if team == 2 else Color("f6a19e")
	tag.set("theme_override_colors/font_color", color)
	
	
func set_tag(new_name : String):
	tag.text = new_name
