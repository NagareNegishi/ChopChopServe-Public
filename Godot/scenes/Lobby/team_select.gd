class_name TeamSelect extends Area3D

@export var team : int
@export var panel : Panel
@export var color : Color
@export var label : Label
@export var outline : Color

func _ready() -> void:
	body_entered.connect(_on_body_enter)
	var temp_style_box : StyleBox = panel.get_theme_stylebox("panel").duplicate()
	temp_style_box.bg_color = color
	panel.add_theme_stylebox_override("panel", temp_style_box)
	label.text = "Join Team %d" % team
	color.a = 1
	label.add_theme_color_override("font_color", outline)
	label.add_theme_color_override("font_outline_color", color)


func _on_body_enter(body : Node3D):
	if !ENetManager.is_host() or body is not Player: return
	
	var player : Player = body
	var player_id = body.name.to_int()
	
	if player_id == -1: return
	
	ENetManager.enet_layer.send_to(1, {  # 1 is always the host
		"type": "request_team_join",
		"player_id": player_id,
		"team": team
	})
	
	player.set_name_color.rpc(player_id, team)
