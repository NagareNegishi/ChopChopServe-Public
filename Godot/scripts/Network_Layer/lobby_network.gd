# lobby_network.gd
extends Control
class_name LobbyNetwork

@export var slot_scene: PlayerSlot
@onready var role_label: Label = %RoleLabel
@onready var player_list_root: VBoxContainer = %PlayerList

var max_slots: int = 4                            # fallback; will be updated from ENet layer
var last_players: Array[int] = []