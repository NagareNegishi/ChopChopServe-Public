extends Node

signal prep_phase()
signal serve_phase()
signal end_phase()
signal time_tick(time)
signal can_sabotage(flag: bool)
signal can_build(flag: bool)

var prep_length : int
var end_length : int
var current_time : int
var day_length : int
var amount_of_days: int # Amount of days is the amount of rounds on one level
var current_day : int # Also as levels to know when to let new or more food come through
var current_phase
var team_1_score : int
var team_2_score : int
var can_send_customers : bool = true
var customer_amount : int
var timer : Timer = Timer.new()

var food_data = {}
var available = []
var has_ended : bool = false

enum Phases{
	PREP,
	SERVE,
	END_ROUND
}

func _init():
	amount_of_days = 5
	current_day = 1
	prep_length = 30 #sec
	day_length = 60 #sec
	end_length = 15
	
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)

func _ready():
	SceneManager.connect("level_ready", Callable(self, "_on_level_started"))
	#food_data = _read_json_file("res://scripts/Food/menu_items_data.json")
	food_data = _read_json_file("res://scripts/Sabotage/menu_items_data.json")


func check_who_wins():
	if team_1_score >= 3: 
		return 1
	elif team_2_score >= 3:
		return 2
	else:
		return 0

func change_phase():
	if current_time <= prep_length:
		_enter_prep_phase()
	elif current_time <= day_length:
		_enter_serve_phase()
	elif current_time > day_length && current_time <= day_length + end_length:
		_enter_end_phase()

func _enter_prep_phase():
	has_ended = false
	current_phase = Phases.PREP
	emit_signal("prep_phase")
	emit_signal("can_build", true)

func _enter_serve_phase():
	current_phase = Phases.SERVE
	emit_signal("serve_phase")
	emit_signal("can_sabotage", true)
	emit_signal("can_build", false)

func _enter_end_phase():
	current_phase = Phases.END_ROUND
	emit_signal("end_phase")  # This might be a mistake? Should this be `end_phase`?
	emit_signal("can_sabotage", false)

	if not has_ended:
		has_ended = true
		current_day += 1
		var available_food_names = _get_available_food_names()
		if available_food_names != null:
			_make_food_items_available(available_food_names)
	
	var team_1_rep = ReputationSystem.get_reputation(1)
	var team_2_rep = ReputationSystem.get_reputation(2)
	
	if team_1_rep > team_2_rep:
		team_1_score+=1
	if team_2_rep > team_1_rep:
		team_2_score+=1
	
	
	if current_time == day_length + end_length:
		current_time = 0



# See if customers are allowed to be sent yet
func check_customers():
	if current_phase == Phases.PREP || current_phase == Phases.END_ROUND:
		can_send_customers = false
	if current_phase == Phases.SERVE:
		can_send_customers = true


func _on_timer_timeout():
	current_time += 1
	emit_signal("time_tick", current_time)
	change_phase()
	check_customers()
	check_who_wins()


func get_customer_check():
	return can_send_customers


func get_current_time():
	return current_time


func get_current_phase():
	return current_phase


func _on_level_started(level: SceneManager.Scene):
	if not _is_gameplay_scene(level):
		return
	
	_start_gameplay_timer()
	
	# Reset when chnaging scenes
	if available:
		for item in available:
			item.is_available = false
	
	available.clear()
	# ----------------------------
	
	var available_food_names = _get_available_food_names()
	_make_food_items_available(available_food_names)


func _is_gameplay_scene(scene: SceneManager.Scene):
	return scene != SceneManager.Scene.LOBBY \
		&& scene != SceneManager.Scene.MAIN_MENU \
		&& scene != SceneManager.Scene.LOBBY_TEST


func end_level(): # what are we doing here?? press okay on screen and then go back to lobby??
	return 0

func _start_gameplay_timer():
	add_child(timer)
	timer.start()


func _get_available_food_names():
	var scene_name = SceneManager.Scene.keys()[SceneManager.current_scene]
	return _make_food_available(scene_name, str(current_day))


func _make_food_items_available(available_names: Array) -> void:
	if available_names.is_empty():
		return
	
	#print("Available food items:", available_names)
	@warning_ignore("static_called_on_instance")
	var menu_classes = MI.get_subclasses()
	for food_name in available_names:
		_mark_food_as_available(food_name, menu_classes)


func _mark_food_as_available(food_name: String, menu_classes: Array) -> void:
	for recipe_script in menu_classes:
		var recipe_instance = recipe_script.new()
		var recipe_name = recipe_instance.get_meal_name()
		
		if recipe_name == food_name:
			recipe_instance.is_available = true
			available.append(recipe_instance)
			#print("%s is now available" % recipe_name)
			break


func _read_json_file(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open JSON file")
		return {}
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var err = json.parse(json_text)
	if err != OK:
		push_error("Failed to parse JSON: %s" % json.get_error_message())
		return {}
	
	return json.data


func _make_food_available(scene, level):
	if scene in food_data:
		if level in food_data[scene]:
			return food_data[scene][level]
		return []


func get_available_recipes():
	return available
