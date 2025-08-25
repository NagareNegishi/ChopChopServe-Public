extends AbstractThrowable
class_name Food


@warning_ignore("unused_signal")
signal cooked
@warning_ignore("unused_signal")
signal changed_food_state
@warning_ignore("unused_signal")
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
var spoil_time = 100 # Timer to food spoils
var state = foodState.RAW # Current state of the food item
var cook_time = 30 # How long it takes to cook 
var quality : int # Measures the quality of the food 
var is_cooking = false # Decides whether or not it should be cooking the ingredient
var time_power : int # How much power/time the appliance is giving/using for the ingredient to be cooked
var current_appliance = null # What appliance is currently being used
var burn_threshold = -(cook_time) # Burn threshold is 2x the time it takes to cook
var current_mesh = raw_mesh # The mesh that is currently being shown  in the scene
var previous_states = ["RAW"] # List of the previous states so that the plate knows 
var is_cooked : bool = false
var chop_time = 4 # Time needed to chop
var freeze_time = 8 # Time needed to freeze
var mix_time = 6 # Time needed to mix/blend
var bake_time = 15 # Time needed to bake
var fry_time = 10 # Time needed to fry

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

var cook_timer : Timer = Timer.new()
func _ready():
	add_child(cook_timer)
	cook_timer.wait_time = 1.0
	cook_timer.one_shot = false
	cook_timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	print("=== TIMER TICK === is_cooking:", is_cooking, " current_appliance:", current_appliance, " time_power:", time_power)
	if is_cooking:
		# Process cooking based on current appliance type
		match current_appliance:
			ApplianceFactory.CookingStyle.CHOP:
				print("About to call chop()")
				chop()
			ApplianceFactory.CookingStyle.BOIL:
				print("About to call boil()")
				boil()
			ApplianceFactory.CookingStyle.BAKE:
				print("About to call bake()")
				bake()
			ApplianceFactory.CookingStyle.BLEND:
				print("About to call mix()")
				mix()
			ApplianceFactory.CookingStyle.PAN_FRY, ApplianceFactory.CookingStyle.DEEP_FRY:
				print("About to call fry()")
				fry()
			_:
				print("Unknown appliance type, can't cook")
	else:
		print("Timer ticked but is_cooking is false!")


# This acts as the clock for the spoiling of the ingredient and also as a check to see if it 
# The ingredient should be cooked or not
func _process(delta):
	if spoil_time != null:
		if spoil_time >= 0:
			spoil_ingredient(delta)
	
	#if is_cooking:
		#boil()

# Delta is passed from process which ticks over every second and therefore has the food spoil 
# in like 50-100 seconds, these times are while we dont have the round times set up and also while
# in testing, spoil times will be extended for actual cooking
func spoil_ingredient(delta : float):
	spoil_time-=delta * cook_timer.wait_time 
	if(spoil_time <= 0 && !is_cooked && state != foodState.SPOILED && previous_states.has("CHOPPED")&& food_name != "Water"):
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
#func cook(appliance_type: ApplianceFactory.CookingStyle):
	#cook_time -=  time_power * cook_timer.wait_time
	#if(cook_time <= 0 && cook_time > burn_threshold && state != foodState.CHOPPED):
		#state = changeState(appliance_type);
		#previous_states.append(state)
		#is_cooked = true
		#print("COOKED FOODDDD   ", food_name)
		##emit_signal("changed_food_state")
		#on_state_change()
		##emit_signal("cooked")
	#if(cook_time <= burn_threshold): # burn_threshold is 2 times the time it takes to cook it
		#state = foodState.BURNT
		##emit_signal("changed_food_state")
		#print("BURNTTTT FOOOOODDDD  ", food_name)
		#on_state_change()


func chop():
	print("remaining chop time, ", chop_time)
	chop_time -=  time_power * cook_timer.wait_time 
	if chop_time <= 0:
		state = foodState.CHOPPED
		previous_states.append(state)
		is_cooked = true
		print("Food is chopped   ", food_name)
		#emit_signal("changed_food_state")
		on_state_change()
		stop_cooking()

func boil():
	cook_time -=  time_power * cook_timer.wait_time 
	print("Cook time remaining: ", cook_time, " on food item: ", food_name)
	if(cook_time <= 0 && cook_time > burn_threshold):
		state = foodState.BOILED;
		previous_states.append(state)
		is_cooked = true
		print("Food is boiled ", food_name)
		#emit_signal("changed_food_state")
		on_state_change()
		#emit_signal("cooked")
	if(cook_time <= burn_threshold): # burn_threshold is 2 times the time it takes to cook it
		state = foodState.BURNT
		#emit_signal("changed_food_state")
		print("Food is burnt while boiling ", food_name)
		on_state_change()
		stop_cooking()

func bake():
	bake_time -= time_power * cook_timer.wait_time
	if bake_time <= 0 && bake_time > -(bake_time):
		state = foodState.BAKED
		previous_states.append(state)
		is_cooked = true
		print("Food is baked   ", food_name)
		on_state_change()
	elif bake_time <= -(bake_time):
		state = foodState.BURNT
		print("Food is burnt while baking   ", food_name)
		on_state_change()
		stop_cooking()

func fry():
	fry_time -= time_power
	if fry_time <= 0 && fry_time > -(fry_time):
		state = foodState.FRIED
		previous_states.append(state)
		is_cooked = true
		print("Food is fried   ", food_name)
		on_state_change()
	elif fry_time <= -(fry_time):
		state = foodState.BURNT
		print("Food is burnt while frying   ", food_name)
		on_state_change()
		stop_cooking()


func mix():
	mix_time -= time_power
	if mix_time <= 0:
		state = foodState.MIXED
		previous_states.append(state)
		print("Food is mixed   ", food_name)
		on_state_change()
		stop_cooking()


func freeze():
	freeze_time -= time_power
	if freeze_time <= 0:
		state = foodState.FROZEN
		previous_states.append(state)
		is_cooked = true
		print("Food is frozen   ", food_name)
		on_state_change()
		stop_cooking()

# Called by the appliance to cook the food passing in the power/time to cook it and the
# cooking style as well as this will determine what it looks like
func startCooking(time: int, appliance_type: ApplianceFactory.CookingStyle):
	time_power = time
	current_appliance = appliance_type
	
	if !cook_timer.is_inside_tree():
		print("adding it as child")
		add_child(cook_timer)
	
	if !is_cooking:
		is_cooking = true
		match appliance_type:
			ApplianceFactory.CookingStyle.CHOP:
				print("Reset chop_time to:", chop_time)
				cook_timer.wait_time = 0.1
				chop_time = 4  # Reset chop time
			ApplianceFactory.CookingStyle.BAKE:
				cook_timer.wait_time = 1.0
				bake_time = 15  # Reset bake time
			ApplianceFactory.CookingStyle.BLEND:
				cook_timer.wait_time = 1.0
				mix_time = 6  # Reset mix time
			ApplianceFactory.CookingStyle.PAN_FRY, ApplianceFactory.CookingStyle.DEEP_FRY:
				cook_timer.wait_time = 1.0
				fry_time = 10  # Reset fry time
			ApplianceFactory.CookingStyle.BOIL:
				cook_timer.wait_time = 1.0
				cook_time = 30  # Reset cook time for boiling
	#emit_signal("cooking")
	
	if cook_timer.timeout.is_connected(_on_timer_timeout):
		print("Signal is connected properly")
	else:
		print("ERROR: Signal is NOT connected!")
		# Try to reconnect
		cook_timer.timeout.connect(_on_timer_timeout)
	
	cook_timer.start()
	print("Timer started - cook_timer.is_stopped():", cook_timer.is_stopped())
	print("Timer wait_time:", cook_timer.wait_time)
	print("Timer time_left:", cook_timer.time_left)
	


# Lets either the appliance or the player tell the food to stop cooking when it 
# gets taken out or off the appliance
func stop_cooking():
	is_cooking = false
	time_power = 0
	current_appliance = null
	print("the states of the food cooking", food_name, state)
	cook_timer.stop()
	set_quality()

# For the appliance to set a new cooking time when new ingredients are added to the appliance so that
# all the ingredients cook at the same time
func set_cook_time(time: float):
	cook_time = time
# Lets the appliance get the cooking time of the ingredient
func get_cook_time():
	return cook_time

func set_quality():
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
		meshName.visible = changeTo

func current_visibility(changeTo: bool):
	current_mesh.visible = changeTo

func change_collisions():
	self.collision_layer = 0
	self.collision_mask = 0
