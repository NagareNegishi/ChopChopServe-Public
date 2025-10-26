class_name UIGameState
extends Control

var game_state : GameStateTest :
	set(value):
		_connect_time_signal(value)
		_connect_phase_signal(value)
		_connect_day_signal(value)

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



func _connect_time_signal(value : GameStateTest):
	if !value: return
	_set_time(value.current_time)
	value.time_changed.connect(_set_time)

func _connect_phase_signal(value : GameStateTest):
	if !value: return
	value.phase_changed.connect(_set_phase)

func _connect_day_signal(value : GameStateTest):
	if !value: return
	_set_day(value.current_day)
	value.day_changed.connect(_set_day)


func seconds2hhmmss(total_seconds: float) -> String:
	#total_seconds = 12345
	var seconds:int = fmod(total_seconds , 60.0)
	var minutes:int   =  int(total_seconds / 60.0) % 60
	var hhmmss_string:String = "%01d:%02d" % [minutes, seconds]
	return hhmmss_string



func _set_phase(phase : GameStateTest.Phases):
	if phase == GameStateTest.Phases.END_GAME: return
	$Main/Phase.visible = true
	$Main/Phase.text = GameStateTest.Phases.keys()[phase]
	$Main/Phase2.text = GameStateTest.Phases.keys()[phase] + "  Phase"
	await get_tree().create_timer(4).timeout
	$Main/Phase.visible = false
	

func _set_time(time : float):
	$Main/Time.text = seconds2hhmmss(time)

func _set_day(day : int):
	$Main/Day.text = "Day " + str(day)
	$Main/Phase/DayInfo.text = "Day "+ str(day)
