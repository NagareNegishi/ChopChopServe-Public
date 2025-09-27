class_name NameTag extends Control

@onready var tag : Label = $Label


func set_color(player_id : int):
	var team : int = ENetManager.get_team(player_id)
	var color : Color = Color("fff6ae") if team == 2 else Color("f6a19e")
	tag.set("theme_override_colors/font_color", color)


func set_tag(new_name : String):
	new_name = new_name if new_name.length() > 0 else "DEFAULT_NAME"
	tag.text = new_name
