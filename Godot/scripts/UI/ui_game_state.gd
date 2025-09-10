class_name UIGameState
extends Control


func _ready() -> void:
	var local_player : Player = GlobalScript.get_local_player()
	set_reputation(1, ReputationSystem.total_rep_team.get(1))
	set_reputation(2, ReputationSystem.total_rep_team.get(2))
	ReputationSystem.reputation_changed.connect(set_reputation)
	CurrencySystem.currency_changed.connect(set_money)

func set_reputation(team : int, amount : int) -> bool:
	if team != 1 && team != 2:
		return false
	
	amount = clamp(amount, 0, 100)
	
	match team:
		1:
			$Team1/Team1_Rep.text = str(amount)
		2:
			$Team2/Team2_Rep.text = str(amount)
		_:
			return false
			
	return true;


func set_money(team : int, amount : int) -> bool:
	if team != 1 && team != 2 || !GlobalScript.get_local_player():
		return false
	
	if GlobalScript.get_local_player().get_team() != team:
		return true
	
	$Main/Money.text = "$" + str(amount)
	return true
