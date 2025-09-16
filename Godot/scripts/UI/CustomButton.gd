extends Button

func _ready() -> void:
	self.mouse_entered.connect(_hovered)
	
func _hovered() -> void:
	pass

func _unhovered() -> void:
	pass
