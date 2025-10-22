class_name NameTag extends Control

@onready var tag : Label = $Label


func set_color(player_id : int):
	var team : int = ENetManager.get_team(player_id)
	set_color_manual(player_id, team)

func set_color_manual(player_id : int, t : int):
	var color : Color
	var outline : Color
	match t:
		2: color = Color("ff6f70")
		1: color = Color("e7d43a")
		_: color = Color8(249,249,249,255)
	match t:
		2: outline = Color("f79b8c")
		1: outline = Color("fff5a5")
		_: outline = Color("8f8f8f")
	print(t)
	tag.set("theme_override_colors/font_color", color)
	tag.add_theme_color_override("font_outline_color", outline)

func set_tag(new_name : String):
	new_name = new_name if new_name.length() > 0 else "DEFAULT_NAME"
	tag.text = new_name
