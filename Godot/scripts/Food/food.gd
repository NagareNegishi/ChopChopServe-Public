extends AbstractPickup
class_name Food

# food needs to have a cooking time


signal cooked
signal changed_food_state
signal cooking
# This gets reset in the other methods it is just default
var food_name = "Default_foodState"
var spoil_time = 80 # Timer to food spoils
var state = foodState.RAW # Current state of the food item
var cook_time = 50 # How long it takes to cook 
var quality : int # TODO: Implement a quality system so that if you dont make good food it matters
var is_cooking = false;
var time_power = 0
var current_appliance = null;
var burn_threshold = -(cook_time) # this is the equivalent of them cooking it twice
# Different state on the on the food item
enum foodState{
	RAW,
	COOKED,
	CHOPPED,
	BOILED,
	MIXED,
	SPOILED,
	BURNT
}

enum applianceType{
	OVEN,
	CHOPPING_BOARD,
	POT,
	PAN,
	BOWL
}

func _process(delta):
	spoil_time-=1;
	if(spoil_time <= 0 && state != foodState.COOKED):
		state = foodState.SPOILED
		emit_signal("changed_foodState")
		quality = 0
	
	if is_cooking:
		cook(time_power, current_appliance)

# Called by the appliance to cook the food passing in the power/time to cook it and the
# appliance type
func cook(time: int, appliance_type: applianceType):
	cook_time -=  time_power
	if(cook_time <= 0):
		state = changeState(appliance_type);
		emit_signal("changed_foodState")
		emit_signal("cooked")
	if(cook_time <= burn_threshold): # burn_threshold is 2 times the time it takes to cook it
		state = foodState.BURNT
		emit_signal("changed_foodState")

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
			
		applianceType.BOWL:
			return foodState.MIXED
			
		applianceType.POT:
			return foodState.BOILED
		_:
			return foodState.RAW # Default case
