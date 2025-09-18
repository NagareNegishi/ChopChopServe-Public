extends Control

@onready var rep_label = $ReputationNumber
@onready var cur_label = $CurrencyNumber

func _ready() -> void:
	#ReputationSystem.reputation_changed.connect(_on_reputation_changed)
	#CurrencySystem.currency_changed.connect(_on_currency_changed)
	GamePhases.cook_timer_on.connect(_on_cook_timer_on)
	GamePhases.prep_timer_on.connect(_on_prep_timer_on)

# Change labels with new values
func _on_reputation_changed(new_reputation: int) -> void:
	rep_label.text = "Reputation: %d" % new_reputation

func _on_currency_changed(new_currency: int) -> void:
	cur_label.text = "Currency: %d" % new_currency

# On Reputation buttons pressed
func _on_add_rep_button_pressed() -> void:
	ReputationSystem.add_reputation(1, 20)

func _on_minus_rep_button_pressed() -> void:
	ReputationSystem.minus_reputation(2,20)

# On Currency buttons pressed
func _on_minus_cur_button_pressed() -> void:
	CurrencySystem.minus_currency(2, 150)

func _on_add_cur_button_pressed() -> void:
	CurrencySystem.add_currency(1, 200)


# Cook Timer Stuff
# On cook timer on signal listener
func _on_cook_timer_on(cook: bool) -> void:
	if cook:
		print("Cook timer is on")
		GamePhases.start_cooking_time()	
	else:
		print("Cook timer is off")

func _on_cook_button_pressed() -> void:
	GamePhases.cook_timer_on.emit(true)
	print("Cook button pressed")

# Prep Timer Stuff
# On prep timer on signal listener
func _on_prep_timer_on(prep: bool) -> void:
	if prep:
		GamePhases.start_prepping_time()
		print("Prep timer is on")
	else:
		print("Prep timer is off")

func _on_prep_button_pressed() -> void:
	GamePhases.prep_timer_on.emit(true)
	print("prep button pressed")
