extends PanelContainer
class_name PlayerSlot

var player_data: Dictionary

func _ready():
    custom_minimum_size = Vector2(200, 64) # reserve space in lobby

func set_player(data: Dictionary) -> void:
    player_data = data
    %NameLabel.text = data.get("name", "Waiting...")

func get_player() -> Dictionary:
    return player_data
