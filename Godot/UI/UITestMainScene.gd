extends Node

# Reputations and Currency Labels
@onready var rep_1 = $Scores/TeamOne/Reputation_1
@onready var rep_2 = $Scores/TeamTwo/Reputation_2

@onready var cur_1 = $Scores/TeamOne/Currency_1
@onready var cur_2 = $Scores/TeamTwo/Currency_2

func _ready() -> void:
	ReputationSystem.reputation_changed.connect(_on_reputation_changed)
	CurrencySystem.currency_changed.connect(_on_currency_changed)

######## Reputation and Currency #########

# --------------- Team One ---------------
# Reputation
func _on_rep_add_button_1_pressed() -> void:
	ReputationSystem.add_reputation(1, 20)

func _on_rep_minus_button_1_pressed() -> void:
	ReputationSystem.minus_reputation(1, 10)

# Currency
func _on_cur_add_button_1_pressed() -> void:
	CurrencySystem.add_currency(1, 20)

func _on_cur_minus_button_1_pressed() -> void:
	CurrencySystem.minus_currency(1, 10)

# --------------- Team Two ---------------
# Reputation
func _on_rep_add_button_2_pressed() -> void:
	ReputationSystem.add_reputation(2, 20)

func _on_rep_minus_button_2_pressed() -> void:
	ReputationSystem.minus_reputation(2, 10)

# Currency
func _on_cur_add_button_2_pressed() -> void:
	CurrencySystem.add_currency(2, 20)

func _on_cur_minus_button_2_pressed() -> void:
	CurrencySystem.minus_currency(2, 10)

# --------------- Signals ---------------
# Change the Labels when rep or cur is gained or lost
# Reputation
func _on_reputation_changed(teamID: int, new_reputation: float) -> void:
	if teamID == 1:
		rep_1.text = "Reputation: %d" % new_reputation
	elif teamID == 2:
		rep_2.text = "Reputation: %d" % new_reputation

# Currency
func _on_currency_changed(teamID: int, new_currency: float) -> void:
	if teamID == 1:
		cur_1.text = "Currency: %d" % new_currency
	elif teamID == 2:
		cur_2.text = "Currency: %d" % new_currency

######## Sabotage ########
# Water Spill
func _on_water_spill_pressed() -> void:
	var teamID = _get_player_teamID()
	print("\n teamID \n")
	SabotageSystem.request_sabotage.rpc_id(1, teamID, 1)

# Fire Start
# Might need to request another variable in this
# for the specific appliance
func _on_fire_pressed() -> void:
	print("\n teamID \n")
	var teamID = _get_player_teamID()
	#ENetManager.get_my_id()
	#ENetManager.is_host()
	# Need to make it work with the different teams
	# need to not make this hardcoded
	SabotageSystem.request_sabotage.rpc_id(1, teamID, 2)
	#SabotageSystem.request_sabotage.rpc_id(1, 1, 2)

func _on_water_spill_pressed_2() -> void:
	print("in the second one !!")
	#pass # Replace with function body.

# Do I actually need this?
func _on_fire_pressed_2() -> void:
	print("\n TEAM TWO \n")
	print("\n \n ENetManager.get_my_id(): ", ENetManager.get_my_id())
	SabotageSystem.request_sabotage.rpc_id(1, 2, 2)
	pass # Replace with function body.

	#### teamID ####
func _get_player_teamID() -> int:
	var my_id = ENetManager.get_my_id()

	if my_id == 1 :
		return 1
	else:
		return 2
