class_name GameStateTest
extends Node

@export var SERVE_TIME : int = 5
@export var PREP_TIME : int = 5
@export var amount_of_days: int = 5  # Amount of days is the amount of rounds on one level

var current_time : float = PREP_TIME
var current_day : int = 1
var current_phase : Phases = Phases.PREP
var can_spawn_customers : bool = false
var team_1_score : int = 0
var team_2_score : int = 0

var timer : Timer = Timer.new()
var food_data = {}
var available : Array

@export var food_court : FoodCourt

signal time_changed(time : float)
signal day_changed(day : int)
signal recipe_added(recipe : MenuItem)
signal phase_changed(phase : Phases)
signal score_update()

enum Phases{
	PREP,
	SERVE,
	END_ROUND
}

func _ready_host():
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.stop()
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	var available_food_names = GameState._get_available_food_names()
	GameState._make_food_items_available(available_food_names)
	CurrencySystem.minus_currency(1, 9800)
	CurrencySystem.minus_currency(2, 9800)
	UIManager.recipe_screen.done.connect(_start_prep)
	GameState.food_data = GameState._read_json_file("res://scripts/Food/menu_items_data.json")
	await get_tree().create_timer(1).timeout

	GlobalScript.get_local_player().disable_controls(true, true)
	
	await get_tree().create_timer(6.5).timeout
	
	var recipes = GameState.get_available_recipes()
	UIManager.show_recipe(recipes.get(recipes.size() - 1))
	return

func _ready() -> void:
	if ENetManager.is_host(): _ready_host()
	await get_tree().create_timer(1).timeout
	GlobalScript.get_local_player().disable_controls(true, true)
	

func change_phase():
	timer.stop()
	match current_phase:
		Phases.PREP: #GOTO SERVE PHASE
			current_phase = Phases.SERVE
			current_time = SERVE_TIME
			spawn_customer()
			timer.start()

		Phases.SERVE: #GOTO END PHASE
			current_phase = Phases.END_ROUND
			timer.stop()
			if check_if_game_finshed(): return
			await get_tree().create_timer(3).timeout
			change_phase()

		Phases.END_ROUND: #GOTO PREP
			GameState.food_data = GameState._read_json_file("res://scripts/Food/menu_items_data.json")
			current_phase = Phases.PREP
			if check_if_game_finshed(): return
			UIManager.show_recipe(soup_tomato.new())
			current_time = PREP_TIME
			can_spawn_customers
			timer.start()
			current_day += 1
			_client_day_change.rpc(current_day)
			

	rpc("_client_phase_change", current_phase)



func _on_timer_timeout():
	if current_time <= 0 && Phases.END_ROUND != current_phase: 
		change_phase()
	
	current_time -= 1
	rpc("_client_time_change", max(0,current_time))


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

@rpc("authority", "call_local")
func _client_day_change(day : int):
	emit_signal("day_changed", day)

func _start_prep():
	timer.start()
	disable_controls.rpc(false)
	_client_phase_change.rpc(current_phase)


@rpc("any_peer","call_local")
func disable_controls(disbale : bool):
	for p : Player in GlobalScript.get_all_players(): p.disable_controls(disbale, disbale)


func check_if_game_finshed() -> bool:
	return current_day >= amount_of_days


func spawn_customer():
	can_spawn_customers = true
	await get_tree().create_timer(0.1).timeout
	can_spawn_customers = false
