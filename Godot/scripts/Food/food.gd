extends Node3D
class_name Food

# food needs to have a cooking time


signal cooked
# This gets reset in the other methods it is just default
var food_name = "Default_food_name"
var spoil_time = 80 # Timer to food spoils
var state = foodState.RAW # Current state of the food item
var cook_time = 50 # How long it takes to cook 
# Different state on the on the food item
enum foodState{
	RAW,
	COOKED,
	SPOILED,
	BURNT
}

func _process(delta):
	spoil_time-=1;
	if(spoil_time <= 0 && state != foodState.COOKED):
		state = foodState.SPOILED


func cook(time: int):
	cook_time -= time 
	if(cook_time <= 0):
		state = foodState.COOKED
		emit_signal("cooked")
	if(cook_time <=-2*(time)):
		state = foodState.BURNT
