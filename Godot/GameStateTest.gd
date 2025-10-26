class_name GameStateTest
extends Node

@export var SERVE_TIMES : Array[int] = [120, 140, 160, 170, 180, 210]
@export var INITAL_PREP_TIME : int = 60
@export var PREP_TIME : int = 45
@onready var amount_of_days: int = max(1, SERVE_TIMES.size())  # Amount of days is the amount of rounds on one level

var current_time : float = INITAL_PREP_TIME
var current_day : int = 0
var current_phase : Phases = Phases.SERVE
var can_spawn_customers : bool = false
var end_ui_scene = preload("res://UI/UI_end_game.tscn")
var end_ui = end_ui_scene.instantiate()

@onready var timer : Timer = Timer.new()
@onready var customer_check : Timer = Timer.new()
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
	END_GAME
}

func _ready_host():
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.stop()
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
	customer_check.wait_time = 0.1
	customer_check.one_shot = false
	customer_check.stop()
	customer_check.timeout.connect(_on_check_customers)
	add_child(customer_check)
	
	CurrencySystem.minus_currency(1, 9000)
	CurrencySystem.minus_currency(2, 9000)
	UIManager.recipe_screen.done.connect(_start_prep)
	GameState.food_data = GameState._read_json_file("res://scripts/Food/menu_items_data.json")
	GameState.current_day = 0
	await get_tree().create_timer(1).timeout

	GlobalScript.get_local_player().disable_controls(true, true)
	
	await get_tree().create_timer(4.5).timeout
	change_phase()

func _ready() -> void:
	if ENetManager.is_host(): _ready_host()
	await get_tree().create_timer(1).timeout
	GlobalScript.get_local_player().disable_controls(true, true)
	

func change_phase():
	timer.stop()
	match current_phase:
		Phases.PREP: #GOTO SERVE PHASE
			can_spawn_customers = true
			current_phase = Phases.SERVE
			current_time = SERVE_TIMES[current_day - 1]
			rpc("_client_time_change", max(0,current_time))
			timer.start()

		Phases.SERVE: #GOTO PREP PHASE
			if check_if_game_finshed(): return
			await get_tree().create_timer(3).timeout
			GameState.current_day += 1
			current_day += 1
			current_phase = Phases.PREP
			_client_day_change.rpc(current_day)
			rpc("_client_phase_change", current_phase)
			await get_tree().create_timer(3).timeout
			load_recipes.rpc(current_day)
			var recipes = GameState._get_available_food_names()
			if current_day % 2 == 1: 
				UIManager.show_recipe(recipes.get(recipes.size() - 1))
				return
			_start_prep()
			return

		Phases.END_GAME: #GOTO PREP
			can_spawn_customers = false
			end_game.rpc()
			return

	rpc("_client_phase_change", current_phase)



func _on_timer_timeout():
	if current_time <= 0 && check_if_game_finshed(): 
		current_phase = Phases.END_GAME
		customer_check.start()
		timer.stop()
		return
	elif current_time <= 0 && Phases.SERVE == current_phase:
		customer_check.one_shot = false
		can_spawn_customers = false
		customer_check.start()
		timer.stop()
		return
	elif  current_time <= 0:
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
	current_time = PREP_TIME if current_day != 1 else INITAL_PREP_TIME
	rpc("_client_time_change", max(0,current_time))
	timer.start()
	can_spawn_customers = false
	disable_controls.rpc(false)


@rpc("any_peer","call_local")
func disable_controls(disbale : bool):
	for p : Player in GlobalScript.get_all_players(): p.disable_controls(disbale, disbale)


func check_if_game_finshed() -> bool:
	return (current_day >= amount_of_days && current_phase == Phases.SERVE) or \
	ReputationSystem.get_reputation(1) <= 0 or ReputationSystem.get_reputation(2) <= 0


func spawn_customer():
	can_spawn_customers = true
	await get_tree().create_timer(1.3).timeout
	can_spawn_customers = false

func _on_check_customers():
	if !get_tree().get_nodes_in_group("Customer").is_empty(): return
	customer_check.stop()
	change_phase()


@rpc("any_peer", "call_local")
func load_recipes(day : int):
	current_day = day
	GameState.current_day = day
	GameState.reset_recipes()
	var available_food_names = GameState._get_available_food_names()
	GameState._make_food_items_available(available_food_names)

@rpc("any_peer", "call_local")
func end_game():
	disable_controls(true)
	add_child(end_ui)
	end_ui.set_to_visible()
	remove_child(timer)
