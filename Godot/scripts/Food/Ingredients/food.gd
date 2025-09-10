extends AbstractThrowable
class_name Food


@warning_ignore("unused_signal")
signal cooked
@warning_ignore("unused_signal")
signal changed_food_state
@warning_ignore("unused_signal")
signal cooking

#Meshes
@export var raw_mesh: MeshInstance3D = null
@export var cooked_mesh: MeshInstance3D = null
@export var spoiled_mesh: MeshInstance3D = null
@export var burnt_mesh: MeshInstance3D = null
@export var chopped_mesh: MeshInstance3D = null
@export var frozen_mesh: MeshInstance3D = null
@export var mixed_mesh: MeshInstance3D = null
@export var texture : Texture2D = null



# This gets reset in the other methods it is just default
var food_name = "Default_foodState"
var previous_states = ["RAW"] # List of the previous states so that the plate knows 
var state = foodState.RAW # Current state of the food item
var current_mesh = raw_mesh # The mesh that is currently being shown  in the scene
var quality : int # Measures the quality of the food 
var time_power : int # How much power/time the appliance is giving/using for the ingredient to be cooked
var current_appliance = null # What appliance is currently being used
var current_cooking_style: ApplianceFactory.CookingStyle

var is_cooking = false # Decides whether or not it should be cooking the ingredient
var is_cooked : bool = false

# --------------------------- COOKING TIMES -----------------------------------
var BOILED_time = 30 # How long it takes to cook 
var boil_burn = -30
var CHOPPED_time = 2 # Time needed to chop
var FROZEN_time = 8 # Time needed to freeze
var MIXED_time = 6 # Time needed to mix/blend
var BAKED_time = 15 # Time needed to bake
var baked_burn = -15
var FRIED_time = 10 # Time needed to fry
var fry_burn = -10
var spoil_time = 100 # Timer to food 

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
	# Timer set up
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
				chop()
			ApplianceFactory.CookingStyle.BOIL:
				boil()
			ApplianceFactory.CookingStyle.BAKE:
				bake()
			ApplianceFactory.CookingStyle.BLEND:
				mix()
			ApplianceFactory.CookingStyle.PAN_FRY, ApplianceFactory.CookingStyle.DEEP_FRY:
				fry()
			_:
				push_error("Unknown appliance passed to _on_timer_timeout in food.gd please
				make sure the cookingstyle is in the match statement, appliance passed: ", current_appliance)
	else:
		push_error("Timer ticked but is_cooking is false!, something is wrong in food.gd logic :/")


# This acts as the clock for the spoiling of the ingredient and also as a check to see if it 
# The ingredient should be cooked or not
func _process(delta):
	if spoil_time != null:
		if spoil_time >= 0:
			spoil_ingredient(delta)
	

# Delta is passed from process which ticks over every second and therefore has the food spoil 
# in like 50-100 seconds, these times are while we dont have the round times set up and also while
# in testing, spoil times will be extended for actual cooking
func spoil_ingredient(delta: float):
	spoil_time-=delta
	if(spoil_time <= 0 && !is_cooked && state != foodState.SPOILED && previous_states.has("CHOPPED")&& food_name != "Water"):
		state = foodState.SPOILED
		#emit_signal("changed_food_state")
		on_state_change()
		previous_states.append(state)
		quality = 0


func convert_enum_to_string(enum_name: foodState)-> String:
	match(enum_name):
		foodState.RAW:
			return "RAW"
		foodState.BAKED:
			return "BAKED"
		foodState.CHOPPED:
			return "CHOPPED"
		foodState.FROZEN:
			return "FROZEN"
		foodState.BOILED:
			return "BOILED"
		foodState.MIXED:
			return "MIXED"
		foodState.FRIED:
			return "FRIED"
		foodState.SPOILED:
			return "SPOILED"
		foodState.BURNT:
			return "BURNT"
		_:
			return "RAW"

# -------------------------TYPES OF COOKING------------------------------------
func chop():
	CHOPPED_time -= time_power * cook_timer.wait_time 
	check_processed(foodState.CHOPPED, CHOPPED_time, 0, true)

func boil():
	BOILED_time -= time_power * cook_timer.wait_time 
	check_processed(foodState.BOILED, BOILED_time, boil_burn, false)
	check_burnt(BOILED_time, boil_burn)

func bake():
	BAKED_time -= time_power * cook_timer.wait_time 
	check_processed(foodState.BAKED, BAKED_time, baked_burn, false)
	check_burnt(BAKED_time, baked_burn)

func fry():
	FRIED_time -= time_power * cook_timer.wait_time 
	check_processed(foodState.FRIED, FRIED_time, fry_burn, false)
	check_burnt(FRIED_time, fry_burn)

func mix():
	MIXED_time -= time_power * cook_timer.wait_time 
	check_processed(foodState.MIXED, MIXED_time, 0, true)

func freeze():
	FROZEN_time -= time_power * cook_timer.wait_time 
	check_processed(foodState.FROZEN, FROZEN_time, 0, true)

# -------------------------END OF COOKING TYPES---------------------------------
func check_processed(s: foodState, time_a:int, time_b:int, stop:bool):
	print("Cook time remaining: ", time_a, " on food item: ", food_name)
	if(time_a <= 0 && time_a > time_b):
		state = s;
		if !previous_states.has(convert_enum_to_string(state)):
			previous_states.append(convert_enum_to_string(state))
		is_cooked = true
		print("Food is done ", food_name)
		#emit_signal("changed_food_state")
		if stop:
			stop_cooking()
		on_state_change()


func check_burnt(time_a, time_b):
	if(time_a <= time_b): # -BOILED_time is 2 times the time it takes to cook it
		state = foodState.BURNT
		#emit_signal("changed_food_state")
		on_state_change()
		stop_cooking()

# Called by the appliance to cook the food passing in the power/time to cook it and the
# cooking style as well as this will determine what it looks like
func startCooking(time: int, appliance_type: ApplianceFactory.CookingStyle):
	time_power = time
	current_appliance = appliance_type
	
	if !cook_timer.is_inside_tree():
		add_child(cook_timer)
	
	if !cook_timer.timeout.is_connected(_on_timer_timeout):
		cook_timer.timeout.connect(_on_timer_timeout)
	current_cooking_style = appliance_type
	if !is_cooking:
		is_cooking = true
		match appliance_type:
			ApplianceFactory.CookingStyle.CHOP:
				if CHOPPED_time <= 0:
					CHOPPED_time = 2 # Reset chop time
			ApplianceFactory.CookingStyle.BAKE:
				if BAKED_time <= 0:
					BAKED_time = 15  # Reset bake time
			ApplianceFactory.CookingStyle.BLEND:
				if MIXED_time <= 0:
					MIXED_time = 6  # Reset mix time
			ApplianceFactory.CookingStyle.PAN_FRY, ApplianceFactory.CookingStyle.DEEP_FRY:
				if FRIED_time <= 0:
					FRIED_time = 10  # Reset fry time
			ApplianceFactory.CookingStyle.BOIL:
				if BOILED_time <= 0:
					BOILED_time = 30  # Reset cook time for boiling
	#emit_signal("cooking")
	cook_timer.start()


# Lets either the appliance or the player tell the food to stop cooking when it 
# gets taken out or off the appliance
func stop_cooking():
	is_cooking = false
	time_power = 0
	print("the states of the food cooking", food_name, state)
	cook_timer.stop()
	set_quality(current_cooking_style)
	#print("QUALITYYYYYYYYYYYYYYYYYY: ", quality)
	current_appliance = null


func get_cooking_type(style: ApplianceFactory.CookingStyle):
	match(style):
		ApplianceFactory.CookingStyle.BAKE:
			return "BAKED"
			
		ApplianceFactory.CookingStyle.CHOP:
			return "CHOPPED"
			
		ApplianceFactory.CookingStyle.BLEND:
			return "MIXED"
			
		ApplianceFactory.CookingStyle.BOIL:
			return "BOILED"
			
		ApplianceFactory.CookingStyle.DEEP_FRY, ApplianceFactory.CookingStyle.PAN_FRY:
			return "FRIED"
		_:
			push_error("Unkown cooking style passed to get_cooking_style in food.gd")


# For the appliance to set a new cooking time when new ingredients are added to the appliance so that
# all the ingredients cook at the same time
func set_cook_time(time: float, style: ApplianceFactory.CookingStyle):
	match(style):
		ApplianceFactory.CookingStyle.BAKE:
			BAKED_time = time
			
		ApplianceFactory.CookingStyle.CHOP:
			CHOPPED_time = time
			
		ApplianceFactory.CookingStyle.BLEND:
			MIXED_time = time
			
		ApplianceFactory.CookingStyle.BOIL:
			BOILED_time = time
			
		ApplianceFactory.CookingStyle.DEEP_FRY, ApplianceFactory.CookingStyle.PAN_FRY:
			FRIED_time = time
			
		_:
			push_error("Unkown cooking style passed to get_cooking_style in food.gd")


# Lets the appliance get the cooking time of the ingredient
func get_cook_time(style: ApplianceFactory.CookingStyle):
	print("In get_cook_time()     cooking style: ", style)
	return get(get_cooking_type(style)+"_time")


func set_quality(style: ApplianceFactory.CookingStyle):
	print("in set quality     cooking style: ", style)
	var time_instance = get(get_cooking_type(style)+"_time")
	if time_instance <= 0 && time_instance > -time_instance:
		quality = clamp(100 - (time_instance / -time_instance) * 100, 0, 100)
	else:
		quality = 0

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
	
	
	#current_mesh = get(get_cooking_type(current_appliance.cookingStyle)+"_mesh")
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



# ----------------------- CHANGING VISIBILITY/COLLISIONS -----------------------
func visibility_of_mesh(meshName: MeshInstance3D, changeTo: bool):
	if meshName != null:
		meshName.visible = changeTo

func current_visibility(changeTo: bool):
	if !current_mesh:
		push_error("No mesh passed to current_visibility() in food.gd")
	current_mesh.visible = changeTo

func change_collisions():
	self.collision_layer = 0
	self.collision_mask = 0
