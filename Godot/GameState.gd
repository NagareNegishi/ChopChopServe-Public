extends Node

var prep_length : float
var current_time : float
var day_length : float
var amount_of_days: int # Amount of days is the amount of rounds on one level
var current_day : int
var current_phase
var team_1_score : int
var team_2_score : int
var can_send_customers : bool = false
var customer_amount : int
var timer : Timer = Timer.new()

enum Phases{
	PREP,
	SERVE,
	END_ROUND
}

func _init():
	print("\n\n the game state script is initialised \n\n")
	amount_of_days = 5
	prep_length = 30
	
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()


func change_phase():
	if current_time <= prep_length:
		current_phase = Phases.PREP
		print("PREP PHASE")
	elif current_time > prep_length && current_time <= day_length:
		current_phase = Phases.SERVE
		print("SERVE PHASE")
	else:
		current_phase = Phases.END_ROUND
		print("END PHASE")

func check_customers():
	if current_phase == Phases.PREP || current_phase == Phases.END_ROUND:
		can_send_customers = false
	if current_phase == Phases.SERVE:
		can_send_customers = true


func _on_timer_timeout():
	print("MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM")
	current_time += 1
	change_phase()
	check_customers()

func get_customer_check():
	return can_send_customers

func get_current_time():
	return current_time

func get_current_phase():
	return current_phase
