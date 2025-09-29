class_name UISabotageNode
extends Control

@export var key_texture : Texture2D
@export var cost : float = 100

@onready var input_bg : ColorRect = $InputBG
@onready var input : TextureRect = $InputBG/Input
@onready var cost_label : Label = $Cost

func _ready() -> void:
	input.texture = key_texture
	CurrencySystem.currency_changed.connect(currency_update)

func currency_update(teamID : int, new_currency : float):
	if teamID != 1:
		return
	
	var font_color : Color = Color("b4f5a4") if new_currency >= cost else Color("b6b6b6c8")
	var input_bg_color : Color = Color("faf9f6") if new_currency >= cost else Color("b6b6b6c8")
	
	cost_label.add_theme_color_override("font_color", font_color)
	input_bg.color = input_bg_color
