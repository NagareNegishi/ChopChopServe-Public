class_name UIGameState
extends Control

func set_reputation(team : int, amount : int) -> bool:
	if team != GlobalScript.Team.TEAM1 || team != GlobalScript.Team.TEAM2:
		return false
	
	amount = clamp(amount, 0, 100)
	
	match team:
		GlobalScript.Team.TEAM1:
			$Team1/Team1_Rep.text = amount
		GlobalScript.Team.TEAM2:
			$Team2/Team2_Rep.text = amount
		_:
			return false
			
	return true;
