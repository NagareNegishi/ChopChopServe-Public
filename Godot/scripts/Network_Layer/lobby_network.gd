# lobby_network.gd
extends Control
class_name LobbyNetwork

@export var slot_scene: PlayerSlot
@onready var role_label: Label = $RoleLabel
@onready var team_label: Label = $TeamLabel
@onready var shuffle_button: Button = $ControlContainer/ShuffleButton
@onready var start_button: Button = $ControlContainer/StartButton
@onready var leave_button: Button = $ControlContainer/LeaveButton
@onready var player_list_root: VBoxContainer = $PlayerList


# fallback; will be updated from ENet layer
var max_slots: int = 4
var current_players: Array[int] = []