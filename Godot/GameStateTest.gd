class_name GameStateTest
extends Node

const SERVE_TIME : int = 180
const PREP_TIME : int = 45
const amount_of_days: int = 5  # Amount of days is the amount of rounds on one level

var current_time : float = PREP_TIME
var current_day : int = 0
var current_phase : Phases = Phases.PREP
var can_send_customers : bool = false

var team_1_score : int = 0
var team_2_score : int = 0

var timer : Timer = Timer.new()

@export var food_court : FoodCourt

signal time_changed(time : float)
signal day_changed(day : int)
signal recipe_added(recipe : MenuItem)
signal phase_changed(phase : Phases)

enum Phases{
	PREP,
	SERVE,
	END_ROUND
}

func _ready() -> void:
	if !ENetManager.is_host(): return 
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()
	#CurrencySystem.minus_currency(1, 9500)
	#CurrencySystem.minus_currency(2, 9500)

func change_phase():
	timer.stop()
	match current_phase:
		Phases.PREP:
			current_phase = Phases.SERVE
			current_time = SERVE_TIME
			timer.start()

		Phases.SERVE:
			current_phase = Phases.PREP
			current_time = PREP_TIME
			timer.start()

		Phases.END_ROUND:
			pass
	
	rpc("_client_phase_change", current_phase)

func check_customers():
	if current_phase == Phases.PREP || current_phase == Phases.END_ROUND:
		can_send_customers = false
	if current_phase == Phases.SERVE:
		can_send_customers = true


func _on_timer_timeout():
	if current_time <= 0: 
		change_phase()
	
	current_time -= 1
	rpc("_client_time_change", current_time)
	#check_customers()

func get_customer_check():
	return can_send_customers

func get_current_time():
	return current_time

func get_current_phase():
	return current_phase

@rpc("authority", "call_local")
func _client_time_change(time : float):
	emit_signal("time_changed", time)


@rpc("authority", "call_local")
func _client_phase_change(phase : Phases):
	emit_signal("phase_changed", phase)
