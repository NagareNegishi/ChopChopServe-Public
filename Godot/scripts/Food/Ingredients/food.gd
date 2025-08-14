extends AbstractThrowable
class_name Food


signal cooked
signal changed_food_state
signal cooking

#Meshes
@export var raw_mesh: MeshInstance3D
@export var cooked_mesh: MeshInstance3D
@export var spoiled_mesh: MeshInstance3D
@export var burnt_mesh: MeshInstance3D
@export var chopped_mesh: MeshInstance3D


# This gets reset in the other methods it is just default
var food_name = "Default_foodState"
var spoil_time = 80 # Timer to food spoils
var state = foodState.RAW # Current state of the food item
var cook_time = 50 # How long it takes to cook 
var quality : int # Measures the quality of the food 
var is_cooking = false
var time_power = 0
var current_appliance = null
var burn_threshold = -(cook_time)
var current_mesh = raw_mesh # this is the equivalent of them cooking it twice
var previous_states = ["RAW"]

# Different state on the on the food item
enum foodState{
	RAW,
	COOKED,
	CHOPPED,
	BOILED,
	MIXED,
	FRIED,
	BLENDED,
	SPOILED,
	BURNT
}

enum applianceType{
	OVEN,
	CHOPPING_BOARD,
	POT,
	PAN,
	BOWL,
	BLENDER,
	FRYER,
	WHISK
}



func _process(delta):
	if spoil_time != null:
		if spoil_time >= 0:
			spoil_ingredient(delta)
	
	if is_cooking:
		cook(current_appliance)

func spoil_ingredient(delta : float):
	spoil_time-=delta;
	if(spoil_time <= 0 && state != foodState.COOKED && state != foodState.SPOILED):
		state = foodState.SPOILED
		on_state_change()
		previous_states.append(state)
		quality = 0
	

# Called by the appliance to cook the food passing in the power/time to cook it and the
# appliance type
func cook(appliance_type: applianceType):
	cook_time -=  time_power
	if(cook_time <= 0):
		state = changeState(appliance_type);
		previous_states.append(state)
		emit_signal("changed_food_state")
		on_state_change()
		emit_signal("cooked")
	if(cook_time <= burn_threshold): # burn_threshold is 2 times the time it takes to cook it
		state = foodState.BURNT
		emit_signal("changed_food_state")
		on_state_change()

func startCooking(time: int, appliance_type: applianceType):
	is_cooking = true;
	time_power = time
	current_appliance = appliance_type
	emit_signal("cooking")


# Lets either the appliance or the player tell the food to stop cooking when it 
# gets taken out or off the appliance
func stopCooking():
	is_cooking = false
	time_power = 0
	current_appliance = null
	setQuality()

func set_cook_time(time: float):
	cook_time = time

func get_cook_time():
	return cook_time

func setQuality():
	if cook_time <= 0 && cook_time > burn_threshold:
		quality = clamp(100 - (cook_time / burn_threshold) * 100, 0, 100)
	else:
		quality = 0

# Changes the foodState of this item depending on what appliance is cooking it
func changeState(appliance_type: applianceType) -> foodState:
	match(appliance_type):
		applianceType.OVEN , applianceType.PAN: # This is just saying either of these states return back cooked state
			return foodState.COOKED
			
		applianceType.CHOPPING_BOARD:
			return foodState.CHOPPED
			
		applianceType.BOWL , applianceType.WHISK:
			return foodState.MIXED
			
		applianceType.POT:
			return foodState.BOILED
				
		applianceType.BLENDER:
			return foodState.BLENDED
			
		applianceType.FRYER:
			return foodState.FRIED
		_:
			return foodState.RAW # Default case
			

func on_state_change():
	if raw_mesh == null:
		return # Meshes not yet initialized
	if cooked_mesh != null:
		cooked_mesh.visible = false
	if spoiled_mesh != null:
		spoiled_mesh.visible = false
	if burnt_mesh != null:
		burnt_mesh.visible = false
	if chopped_mesh != null:
		chopped_mesh.visible = false
	
	raw_mesh.visible = false
	
	match(state):
		foodState.COOKED:
			current_mesh = cooked_mesh
			
		foodState.SPOILED:
			current_mesh = spoiled_mesh
			
		foodState.CHOPPED:
			current_mesh = chopped_mesh
		_:
			current_mesh = raw_mesh
	
	if current_mesh:
		current_mesh.visible = true
		
