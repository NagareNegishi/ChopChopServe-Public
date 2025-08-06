extends Control

@onready var rep_label = $ReputationNumber
@onready var cur_label = $CurrencyNumber

func _ready() -> void:
	print("in UI ready")
	
	ReputationSystem.reputation_changed.connect(_on_reputation_changed)
	CurrencySystem.currency_changed.connect(_on_currency_changed)

# Change labels with new values
func _on_reputation_changed(new_reputation: int) -> void:
	rep_label.text = "Reputation: %d" % new_reputation

func _on_currency_changed(new_currency: int) -> void:
	cur_label.text = "Currency: %d" % new_currency

# On Reputation button presses
func _on_add_rep_button_pressed() -> void:
	print("Reputation add button pressed")
	ReputationSystem.add_reputation(20)

func _on_minus_rep_button_pressed() -> void:
	print("Reputation minus button pressed")
	ReputationSystem.minus_reputation(20)

# On Currency button presses

func _on_minus_cur_button_pressed() -> void:
	print("Currency minus button pressed")
	CurrencySystem.minus_currency(150)

func _on_add_cur_button_pressed() -> void:
	print("Currency Add button pressed")
	CurrencySystem.add_currency(200)
