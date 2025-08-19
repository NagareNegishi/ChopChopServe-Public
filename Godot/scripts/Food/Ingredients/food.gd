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
@export var frozen_mesh: MeshInstance3D
@export var mixed_mesh: MeshInstance3D
@export var texture : Texture2D

# This gets reset in the other methods it is just default
var food_name = "Default_foodState"
var spoil_time = 80 # Timer to food spoils
var state = foodState.RAW # Current state of the food item
var cook_time = 50 # How long it takes to cook 
var quality : int # Measures the quality of the food 
var is_cooking = false # Decides whether or not it should be cooking the ingredient
var time_power : int # How much power/time the appliance is giving/using for the ingredient to be cooked
var current_appliance = null # What appliance is currently being used
var burn_threshold = -(cook_time) # Burn threshold is 2x the time it takes to cook
var current_mesh = raw_mesh # The mesh that is currently being shown  in the scene
var previous_states = ["RAW"] # List of the previous states so that the plate knows 
var is_cooked : bool = false

# Different state on the on the food item
enum foodState{
	RAW, # Not cooked
	BAKED, # cooked in the oven
	CHOPPED, # cut up on the chopping board
	FROZEN, # Cooled/freezed in the freezer
	BOILED, # Boiled in the pot
	MIXED, # Mixed items together in the blender or just mixed them
	FRIED, # Fried in a pan Fried in the deep fryer
	SPOILED, # Ingredient has gone off
	BURNT # Overcooked
}

# This acts as the clock for the spoiling of the ingredient and also as a check to see if it 
# The ingredient should be cooked or not
func _process(delta):
	if spoil_time != null:
		if spoil_time >= 0:
			spoil_ingredient(delta)
	
	if is_cooking:
		cook(current_appliance)

# Delta is passed from process which ticks over every second and therefore has the food spoil 
# in like 50-100 seconds, these times are while we dont have the round times set up and also while
# in testing, spoil times will be extended for actual cooking
func spoil_ingredient(delta : float):
	spoil_time-=delta;
	if(spoil_time <= 0 && !is_cooked && state != foodState.SPOILED):
		state = foodState.SPOILED
		#emit_signal("changed_food_state")
		on_state_change()
		previous_states.append(state)
		quality = 0
	

# This is called by the process function, it has a count down for the amount of time left to cook 
# and when it is cooked it will change the state of the food and also add its new state to the
# list so that the plate knows if the ingredient has gone through all the necessary states to turn 
# into a meal
# We talked about emitting signals when things change to let the server know and thats why there are
# signals but they currently do nothing as i dont think the server has been set up
func cook(appliance_type: ApplianceFactory.CookingStyle):
	cook_time -=  time_power
	if(cook_time <= 0):
		state = changeState(appliance_type);
		previous_states.append(state)
		is_cooked = true
		#emit_signal("changed_food_state")
		on_state_change()
		#emit_signal("cooked")
	if(cook_time <= burn_threshold): # burn_threshold is 2 times the time it takes to cook it
		state = foodState.BURNT
		#emit_signal("changed_food_state")
		on_state_change()

# Called by the appliance to cook the food passing in the power/time to cook it and the
# cooking style as well as this will determine what it looks like
func startCooking(time: int, appliance_type: ApplianceFactory.CookingStyle):
	is_cooking = true;
	time_power = time
	current_appliance = appliance_type
	#emit_signal("cooking")


# Lets either the appliance or the player tell the food to stop cooking when it 
# gets taken out or off the appliance
func stopCooking():
	is_cooking = false
	time_power = 0
	current_appliance = null
	setQuality()

# For the appliance to set a new cooking time when new ingredients are added to the appliance so that
# all the ingredients cook at the same time
func set_cook_time(time: float):
	cook_time = time
# Lets the appliance get the cooking time of the ingredient
func get_cook_time():
	return cook_time

func setQuality():
	if cook_time <= 0 && cook_time > burn_threshold:
		quality = clamp(100 - (cook_time / burn_threshold) * 100, 0, 100)
	else:
		quality = 0

# Changes the foodState of this item depending on what appliance is cooking it
func changeState(appliance_type: ApplianceFactory.CookingStyle) -> foodState:
	match(appliance_type):
		ApplianceFactory.CookingStyle.BAKE:
			return foodState.BAKED
			
		ApplianceFactory.CookingStyle.CHOP:
			return foodState.CHOPPED
			
		ApplianceFactory.CookingStyle.BLEND:
			return foodState.MIXED
			
		ApplianceFactory.CookingStyle.BOIL:
			return foodState.BOILED
			
		ApplianceFactory.CookingStyle.BLEND:
			return foodState.MIXED
			
		ApplianceFactory.CookingStyle.DEEP_FRY, ApplianceFactory.CookingStyle.PAN_FRY:
			return foodState.FRIED
		_:
			return foodState.RAW # Default case
			

# Decides which mesh should be shown in the scene based on the state of the food
func on_state_change():
	if raw_mesh == null:
		return # Meshes not yet initialized
	visibility_of_mesh(cooked_mesh, false)
	visibility_of_mesh(spoiled_mesh, false)
	visibility_of_mesh(burnt_mesh, false)
	visibility_of_mesh(chopped_mesh, false)
	visibility_of_mesh(frozen_mesh, false)
	visibility_of_mesh(mixed_mesh, false)
	visibility_of_mesh(raw_mesh, false)
	
	match(state):
		foodState.BAKED, foodState.BOILED, foodState.FRIED:
			current_mesh = cooked_mesh
			
		foodState.SPOILED:
			current_mesh = spoiled_mesh
			
		foodState.CHOPPED:
			current_mesh = chopped_mesh
			
		foodState.BURNT:
			current_mesh = burnt_mesh
			
		foodState.FROZEN:
			current_mesh = frozen_mesh
			
		foodState.MIXED:
			current_mesh = mixed_mesh
			
		_:
			current_mesh = raw_mesh
	
	visibility_of_mesh(current_mesh, true)

func visibility_of_mesh(meshName: MeshInstance3D, changeTo: bool):
	if meshName != null:
		meshName.visibility = changeTo

func current_visibility(changeTo: bool):
	current_mesh.visibility = changeTo

func change_collisions():
	self.collision_layer = 0
	self.collision_mask = 0
