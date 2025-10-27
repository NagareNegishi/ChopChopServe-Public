class_name UICook extends Control

@export var ingbar : HBoxContainer
@export var pot_txt : TextureRect
@export var tray_txt : TextureRect
@export var pan_txt : TextureRect
@export var mixed_txt : TextureRect
var _cookware
var _info
const self_scene : PackedScene = preload("res://UI/Recipes/UI_Cook.tscn")

func set_info(cookware : String, info : Array):
	var texture = match_text(cookware) 
	for a in [pot_txt, tray_txt, pan_txt, mixed_txt]: a.visible = false
	texture.visible = true
	
	for key : String in info:
		var texture_rect = TextureRect.new()
		texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		var txt_name : String = key
		var regex = RegEx.new()
		regex.compile("\\d")
		if regex.search(txt_name): txt_name = txt_name.left(txt_name.length() - 1)
		texture_rect.texture = ResourceLoader.load("res://assets/textures/ingredients/" + txt_name.to_lower() + ".png")
		ingbar.add_child(texture_rect)


func match_text(t : String):
	match t:
		"BOILED":
			return pot_txt
		"FRIED":
			return pan_txt
		"FIRED":
			return pan_txt
		"BAKED":
			return tray_txt
		"MIXED":
			return mixed_txt
	return null
