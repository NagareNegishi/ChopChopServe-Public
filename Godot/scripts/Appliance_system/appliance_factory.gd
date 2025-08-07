# appliance_factory.gd
## IMPORTANT: All concrete appliances MUST BE in the defined PATH!!
## to be AutoLoaded as ApplianceFactory, expected used example:
## var appliance = ApplianceFactory.create_appliance("stove")
## kitchen.add_child(appliance)
## appliance.place_at(target_position)
extends Node

## All cooking styles supported by Appliance and Food
enum CookingStyle {
    NONE,        # Bench - no cooking, just prep/storage
    HEAT,        # Stove Top - direct heat cooking          ????may be redundant?????
    BAKE,        # Oven
    DEEP_FRY,    # Deep Fryer
    PAN_FRY,     # Frying Pan
	BOIL,        # Pot
    BLEND,       # Blender - mixing/blending
    FREEZE,      # Freezer - cooling/freezing
    CUT,         # Cutting Board with Knife - chopping       we can rename it to chop
    WHISK       # Whisk - mixing
}

# all concrete appliances must be in this folder
const PATH = "res://scripts/Appliance_system/Concrete_classes/"
var book: Dictionary = {}


## Setup the factory
func _ready():
	register_appliances()
	print_book()


## Create an appliance instance of the given type
## @param type: Name of the appliance type to create
## @return: Instance of the appliance or null if not found
func create_appliance(type: String) -> Appliance:
	if not book.has(type):
		push_error("Appliance type '%s' not registered!" % type)
		return null
	var appliance = book[type].new()
	if appliance is Appliance:
		return appliance
	push_error("Registered type '%s' is not an Appliance!" % type)
	return null


## Register a new appliance type with the factory
## @param type: Name of the appliance type
## @param script: Script of appliance, must match with the type
func register_appliance(type: String, script: Script):
	if not script.can_instantiate():
		push_error("Script '%s' cannot be instantiated!" % type)
		return
	book[type] = script


## Register all appliances in the defined directory
func register_appliances():
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
				register_appliance(script_name, script)
			else:
				push_warning("Failed to load script: " + file_name)
		file_name = dir.get_next()


## Print the registered appliances in the factory
func print_book():
	print("Registered appliances:")
	for appliance_name in book:
		var script = book[appliance_name]
		print("- %s -> %s" % [appliance_name, script.get_global_name()])





## for test remove later
func spawn_test_appliance(appliance_type: String):
	var appliance = create_appliance(appliance_type)
	if appliance:
		get_tree().current_scene.add_child(appliance)
		appliance.global_position = Vector3(0, 0, 0)
		
		print("Spawned: ", appliance_type)
	else:
		print("Failed to spawn: ", appliance_type)


func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		spawn_test_appliance("stove")