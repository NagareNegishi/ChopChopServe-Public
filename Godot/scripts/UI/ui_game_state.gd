class_name UIGameState
extends Control

var game_state : GameStateTest :
	set(value):
		_connect_time_signal(value)

func _ready() -> void:
	set_reputation(1, ReputationSystem.total_rep_team.get(1))
	set_reputation(2, ReputationSystem.total_rep_team.get(2))
	ReputationSystem.reputation_changed.connect(set_reputation)
	CurrencySystem.currency_changed.connect(set_money)
	set_money(ENetManager.get_my_team(), CurrencySystem.get_currency(ENetManager.get_my_team()))

func set_reputation(teamID : int, new_reputation : int):
	if teamID != 1 && teamID != 2:
		return
	
	match teamID:
		1:
			$Team1/Team1_Rep.text = str(new_reputation)
		2:
			$Team2/Team2_Rep.text = str(new_reputation)
		_:
			return
			
	return


func set_money(team : int, amount : int) -> bool:
	if team != 1 && team != 2:
		return false
	
	if ENetManager.get_my_team() != team:
		return true
	
	$Main/Money.text = "$" + str(amount)
	return true

func _set_time(time : float):
	print(time)
	$Main/Time.text = seconds2hhmmss(time)

func _connect_time_signal(value):
	_set_time(value.current_time)
	value.time_changed.connect(_set_time)


func seconds2hhmmss(total_seconds: float) -> String:
	#total_seconds = 12345
	var seconds:int = fmod(total_seconds , 60.0)
	var minutes:int   =  int(total_seconds / 60.0) % 60
	var hhmmss_string:String = "%01d:%02d" % [minutes, seconds]
	return hhmmss_string
