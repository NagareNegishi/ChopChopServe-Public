extends Node

# Timers
var prep_timer: Timer
var cook_timer: Timer
# Timer Floats
var prep_time: float = 3.0
var cook_time: float = 3.0
# Phase Booleans
var cooking: bool = false
var prepping: bool = false
# Signals
signal cook_timer_on(cook: bool)
signal prep_timer_on(prep: bool)

func _ready():
	# Preparation Phase Timer
	prep_timer = Timer.new()
	# Add the timer to the current node
	add_child(prep_timer)
	# Set the duration of the timer
	prep_timer.wait_time = prep_time
	# Set to true so it stops
	prep_timer.one_shot = true
	# Connect the timeout signal to a function
	prep_timer.timeout.connect(_on_prep_timer_timeout)

	# Cooking Phase Timer
	cook_timer = Timer.new()
	# Add the timer to the current node
	add_child(cook_timer)
	# Set the duration of the timer
	cook_timer.wait_time = cook_time
	# Set to true so it stops
	cook_timer.one_shot = true
	# Connect the timeout signal to a function
	cook_timer.timeout.connect(_on_cook_timer_timeout)

# PREP Timer Stuff
# Turn the timer on
func start_prepping_time():
	prepping = true
	prep_timer.start()	

# When the Timer turns on
func _on_prep_timer_timeout():
	prepping = false
	prep_timer_on.emit(false)

# COOK Timer Stuff
# Turn timer on
func start_cooking_time():
	cooking = true
	cook_timer.start()

# When the Timer turns off
func _on_cook_timer_timeout():
	cooking = false
	cook_timer_on.emit(false)
