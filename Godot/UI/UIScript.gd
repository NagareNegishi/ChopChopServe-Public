extends Control

@onready var label = $ReputationNumber

func _ready() -> void:
	print("in UI ready")
	ReputationSystem.reputation_changed.connect(_on_reputation_changed)

func _on_reputation_changed(new_reputation: int) -> void:
	label.text = "Reputation: %d" % new_reputation


func _on_add_rep_button_pressed() -> void:
	print("Reputation add button pressed")
	ReputationSystem.add_reputation(20)


func _on_minus_rep_button_pressed() -> void:
	print("Reputation minus button pressed")
	ReputationSystem.minus_reputation(20)
