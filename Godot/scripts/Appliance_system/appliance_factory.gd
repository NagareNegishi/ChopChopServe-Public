# appliance_factory.gd
## IMPORTANT: All concrete appliances MUST BE in the defined PATH!!
## to be AutoLoaded as ApplianceFactory.
## However, most methods are ApplianceManager use only.

## It can be used for testing, for example:
## var appliance = ApplianceFactory._create_appliance("stove")
## kitchen.add_child(appliance)
## appliance.place_at(target_position)
extends Node

## All cooking styles supported by Appliance and Food
enum CookingStyle {
	NONE,        # Bench - no cooking, just prep/storage
	HEAT,        # Stove Top - direct heat cooking
	BAKE,        # Oven
	DEEP_FRY,    # Deep Fryer
	PAN_FRY,     # Frying Pan
	BOIL,        # Pot
	BLEND,       # Blender - mixing/blending
	CHOP         # Cutting Board with Knife - chopping
}

# all concrete appliances must be in this folder
const PATH = "res://scripts/Appliance_system/Concrete_classes/"
var base_scene: PackedScene = preload("res://scenes/Appliance_system/placeable.tscn")
var book: Dictionary = {}

# List of all appliance types to register
const APPLIANCE_TYPES = [
	# Power appliances
	"blender",
	"oven",
	"fryer",
	"stove",
	"stove_with_pot",
	"stove_with_pan",
	# Utility appliances
	"bench",
	"chop_table",
	"cabinet",
	"sink",
	"trash_can",
	"food_factory",
	# Cookware
	"pot",
	"frying_pan",
	"oven_tray",
	"fryer_basket",
	"chopping_board",
]


## Setup the factory
func _ready():
	_register_appliances()
	# For testing only
	# ApplianceManager.appliance_created.connect(_on_test_appliance_created)


## Note: only used by ApplianceManager
## Create an appliance instance of the given type
## @param type: Name of the appliance type to create
## @return: Instance of the appliance or null if not found
func _create_appliance(type: String) -> Appliance:
	if not book.has(type):
		push_error("Appliance type '%s' not registered: %s" % [type, str(book.keys())])
		return null
	var instance = base_scene.instantiate()
	instance.set_script(book[type].script)
	return instance


## Register a new appliance type with the factory
## @param type: Name of the appliance type
## @param script: Script of appliance, must match with the type
func _register_appliance(type: String, script: Script):
	if not script.can_instantiate():
		push_error("Script '%s' cannot be instantiated!" % type)
		return
	# Little wasteful, but need to access instance variables
	var temp_instance = base_scene.instantiate()
	temp_instance.set_script(script)
	if temp_instance is Appliance:
		var price = temp_instance.get_price()
		book[type] = {
			"script": script,
			"price": price
		}
		temp_instance.queue_free()
	else:
		temp_instance.queue_free()
		push_error("Registered type '%s' is not an Appliance!" % type)


## Register all appliances defined in APPLIANCE_TYPES
func _register_appliances():
	for script_name in APPLIANCE_TYPES:
		var script_path = PATH + script_name + ".gd"
		var script: Script = load(script_path)
		if script:
			_register_appliance(script_name, script)
		else:
			push_warning("Failed to load script: " + script_name)


## Register all appliances in the defined directory
## Note: Not used currently, more dynamic implementation
## but packed games do not have same file structure
func _register_appliances_from_folder():
	var dir: DirAccess = DirAccess.open(PATH)
	if not dir:
		push_error("Cannot open directory: " + PATH)
		return
	# Iterate through all files in the directory
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".gd"):
			var script_name = file_name.get_basename()
			var script: Script = load(PATH + file_name)
			if script:
				_register_appliance(script_name, script)
			else:
				push_warning("Failed to load script: " + file_name)
		file_name = dir.get_next()


## Provide the list of valid input for create_appliance()
## @return: Array of strings that can be used with create_appliance()
func get_options() -> Array[String]:
	return book.keys()


# # For testing only, DO NOT USE in production!-------------------------------------------------------

# ## Print the registered appliances in the factory
# func print_book():
# 	print("Registered appliances:")
# 	for appliance_name in book:
# 		var info = book[appliance_name]
# 		print("- %s -> %s (Price: %d)" % [appliance_name, info.script.get_global_name(), info.price])


# ## Test appliance spawning with numpad keys
# const TEST_APPLIANCES = [
# 	"stove_with_pot",      # Numpad 1
# 	"oven",    # Numpad 2
# 	"fryer", # Numpad 3
# 	"blender",    # Numpad 4
# 	"chop_table",      # Numpad 5
# 	"cabinet",       # Numpad 6
# 	"food_factory",       # Numpad 7
# 	"sink",      # Numpad 8
# 	"trash_can",   # Numpad 9
# 	"stove_with_pan"  # Numpad 0
# ]


# ## Bind to input events for testing appliance spawning
# func _input(event):
# 	if event is InputEventKey and event.pressed:
# 		var appliance_index = -1
	
# 		# Check for numpad keys 1-9 + 0
# 		match event.keycode:
# 			KEY_KP_1:
# 				appliance_index = 0
# 			KEY_KP_2:
# 				appliance_index = 1
# 			KEY_KP_3:
# 				appliance_index = 2
# 			KEY_KP_4:
# 				appliance_index = 3
# 			KEY_KP_5:
# 				appliance_index = 4
# 			KEY_KP_6:
# 				appliance_index = 5
# 			KEY_KP_7:
# 				appliance_index = 6
# 			KEY_KP_8:
# 				appliance_index = 7
# 			KEY_KP_9:
# 				appliance_index = 8
# 			KEY_KP_0:
# 				appliance_index = 9

# 		# Spawn the corresponding appliance
# 		if appliance_index >= 0 and appliance_index < TEST_APPLIANCES.size():
# 			ApplianceManager.request_appliance(TEST_APPLIANCES[appliance_index], 0)
# 			print("Numpad %d pressed - spawning %s" % [appliance_index + 1, TEST_APPLIANCES[appliance_index]])


# ## Spawn the appliance in front of the local player for testing
# func _on_test_appliance_created(appliance: Appliance):
# 	var player_id = ENetManager.get_my_id()
# 	print("DEBUG: My ID is ", player_id)

# 	var player = GlobalScript.get_local_player_by_id(player_id)
# 	if player:
# 		# Get player's position and forward direction
# 		var player_pos = player.global_position
# 		var player_forward = -player.global_transform.basis.z
# 		# Spawn distance in front of player
# 		var spawn_distance = 2.0  # Adjust this value as needed
# 		var spawn_position = player_pos + (player_forward * spawn_distance)
# 		spawn_position.y = 1.0
# 		get_tree().current_scene.add_child(appliance)
# 		appliance.global_position = spawn_position
# 		# print("DEBUG: Appliance added to scene at: ", appliance.global_position)
# 	else:
# 		print("DEBUG: No player found!")
