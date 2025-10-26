class_name UISabotageNode
extends Control

@export var key_texture : Texture2D
@export var sabotage_index : int = 0
@export var sabo_image : TextureRect
var cost : int
@onready var input_bg : ColorRect = $InputBG
@onready var input : TextureRect = $InputBG/Input
@onready var cost_label : Label = $Cost

var red_colour : Color = "b6b6b6c8"
var green_colour : Color = "b4f5a4"
const path : String = "res://assets/textures/Sabotage/"
func _ready() -> void:
	$Panel3.visible = false
	input.texture = key_texture
	CurrencySystem.currency_changed.connect(currency_update)
	cost = SabotageSystem.sabotage_costs.get(sabotage_index)
	cost_label.text = str(cost)
	focus_entered.connect(_hovered)
	focus_exited.connect(_unhovered)
	Input.joy_connection_changed.connect(hide_)
	hide_(0, Input.get_connected_joypads().size() >= 1)
	var current_money = CurrencySystem.get_currency(ENetManager.get_my_team())
	
	var font_color : Color = Color(green_colour) if current_money >= cost else Color(red_colour)
	var input_bg_color : Color = Color(green_colour) if current_money >= cost else Color(red_colour)
	
	cost_label.add_theme_color_override("font_color", font_color)
	sabo_image.texture = ResourceLoader.load(path + str(sabotage_index + 1) +".png")

func currency_update(teamID : int, new_currency : float):
	if teamID != ENetManager.get_my_team():
		return
	
	var font_color : Color = Color("b4f5a4") if new_currency >= cost else Color("b6b6b6c8")
	var input_bg_color : Color = Color("faf9f6") if new_currency >= cost else Color("b6b6b6c8")
	
	cost_label.add_theme_color_override("font_color", font_color)
	input_bg.color = input_bg_color

func hide_(d : int, c : bool):
	$InputBG.visible = !c
	$Input.visible = false

func _hovered() -> void:
	$Panel3.visible = true
	$Input.visible = false
	$Input.visible = true

func _unhovered() -> void:
	$Panel3.visible = false
	$Input.visible = false
	$Input.visible = false
	
