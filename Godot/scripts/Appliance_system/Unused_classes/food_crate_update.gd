## Food Crate only provides a one type of ingredient, but takes nothing back.
## player can take food from food crate manually,
##
## Note: the implementation can be simplify by extending Appliance directly,
## however, considering the future extension, I will extend UnPoweredAppliance
class_name FoodCrateUpdate
extends UnPoweredAppliance

@export_group("Supply Settings")
var supply: PackedScene

@export var catergory : Catergory
@export var current_index : float = 0
@onready var wait_timer : Timer = Timer.new()
var food_directory: String = "res://scripts/Food/IngredientScenes/"
var supply_instance: Node
var _switched : bool
var action_held : bool
const wait_time = 0.3
@onready var crate : MeshInstance3D = $Crate
@onready var material : Material = StandardMaterial3D.new()
enum Catergory{
	FRIDGE,
	VEGE,
	FRUIT,
	PANTRY
}

const FOOD_ORDER = {
	Catergory.FRIDGE: [preload("res://scripts/Food/IngredientScenes/beef.tscn"),
					   preload("res://scripts/Food/IngredientScenes/chicken.tscn"),
					   preload("res://scripts/Food/IngredientScenes/Fish.tscn"),
					   preload("res://scripts/Food/IngredientScenes/Milk.tscn")],
					
	Catergory.VEGE: [preload("res://scripts/Food/IngredientScenes/garlic.tscn"),
					preload("res://scripts/Food/IngredientScenes/mushroom.tscn"),
					preload("res://scripts/Food/IngredientScenes/Onion.tscn"),
					preload("res://scripts/Food/IngredientScenes/Potato.tscn")],
	
	Catergory.FRUIT: [preload("res://scripts/Food/IngredientScenes/apple.tscn"),
					 preload("res://scripts/Food/IngredientScenes/pineapple.tscn"),
					 preload("res://scripts/Food/IngredientScenes/Tomato.tscn"),
					 preload("res://scripts/Food/IngredientScenes/pumpkin.tscn")],
					
	Catergory.PANTRY: [ preload("res://scripts/Food/IngredientScenes/Cocoa.tscn"),
					   preload("res://scripts/Food/IngredientScenes/Flour.tscn"),
					   preload("res://scripts/Food/IngredientScenes/Pasta.tscn"),
					   preload("res://scripts/Food/IngredientScenes/cheese.tscn"),
					   preload("res://scripts/Food/IngredientScenes/dough.tscn")]
}


## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/NuFurniture/FoodCrater.glb")
	self.freeze = true
	self.sleeping = true


## Set up the FoodCrate
func _ready():
	super._ready()
	action_interval = 0.5 # small interval to avoid rapid item taking
	_timer_setup()
	_set_affixes()
	_initialize_supply()
	_set_mesh()
	


## Add synchronization properties for the placeable object
func _add_sync_properties(config: SceneReplicationConfig):
	super._add_sync_properties(config)
	config.add_property(NodePath(".:supply_count"))
	config.add_property(NodePath(".:supply"))

## Initialize the supply
func _initialize_supply():
	interactable_component.has_action = true
	if supply and supply.can_instantiate():
		supply_instance = supply.instantiate()
		return
	supply = FOOD_ORDER[catergory][current_index]


# Set the supply script for the food crate
func set_supply(food_name: String):
	var scene_path = food_directory + food_name + ".tscn"
	supply = load(scene_path)
	if supply and supply.can_instantiate():
		supply_instance = supply.instantiate()
		# print("FoodCrate supply set to: ", scene_path.get_file().get_basename())
	else:
		push_error("Failed to load or cannot instantiate scene: " + scene_path)


## Provide food from the crate
## @return: The food item that was taken, or null if not in IDLE status
func take() -> Node:
	if current_status != Status.IDLE:
		push_error("FoodCrate is not in IDLE status, cannot take food")
		return null
	current_status = Status.USING
	action_timer.start()

	var food = supply.instantiate()
	food.name = prefix + str(supply_count)
	supply_count += 1
	ApplianceManager.register_item(food, current_owner, food.name)
	return food


## For Player interaction --------------------------------------------------------------------------

## Perform action depend on what player is holding
## @param _item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(item: Node) -> void:
	if item && item is Food && item.state == Food.foodState.RAW:
		var player : Player = GlobalScript.get_local_player()
		player.server_drop_item(player.get_path(), false)
		rpc("_destroy", item.get_path())
		
	if not item && !action_held:
		take_request()
		return

	if item is Cookware and item._can_accept(supply_instance):
		transfer_request(item)
		return


func _delete_food(item_path : String):
	pass
	
	
## Client-side method to take item, called by host
## @param item_name: The name of the item to take
@rpc("authority", "call_remote", "reliable")
func _client_take(item_name: String) -> void:
	var item = take()
	item.name = item_name
	get_tree().current_scene.add_child(item)


## Request to take an item from this appliance to Player
func take_request() -> void:
	_take_as_host.rpc_id(1, ENetManager.get_my_id())


## Host-side method to handle take requests from clients
## @param player_id: The id of the player who is taking the item
@rpc("any_peer", "call_local", "reliable")
func _take_as_host(player_id: int) -> void:
	if not ENetManager.is_host():
		return
	# host need check to prevent conflicts/ cheating
	var item = take()
	get_tree().current_scene.add_child(item)
	_client_take.rpc(item.name)
	_give_item_to_player.rpc(player_id, item.get_path())


# Client-side method to give item to player, called by host
## @param player_id: The id of the player who is taking the item
## @param item_path: The NodePath of the item to give
@rpc("authority", "call_local", "reliable")
func _give_item_to_player(player_id: int, item_path: NodePath) -> void:
	var item = get_node_or_null(item_path)
	if item:
		var player = GlobalScript.get_local_player_by_id(player_id)
		if player:
			player.server_pickup(player.get_path(), item.get_path())
			


## Transfer food from FoodCrate to Cookware
## @param cookware: The Cookware to transfer food to
func transfer_request(player_cookware: Cookware) -> void:
	var food = take()
	if not food:
		return
	if ENetManager.is_host():
		player_cookware._put(food)
		_client_transfer.rpc(ENetManager.get_my_id(), food.name)
		return
	_transfer_as_host.rpc_id(1, ENetManager.get_my_id())


## Host-side method to handle transfer requests from clients
## @param player_id: The id of the player who is transferring the food
@rpc("any_peer", "call_remote", "reliable")
func _transfer_as_host(player_id: int) -> void:
	if not ENetManager.is_host():
		return
	var player_cookware = GlobalScript.get_local_player_by_id(player_id).item_in_hand
	if player_cookware is Cookware and player_cookware._can_accept(supply_instance):
		var food = take()
		player_cookware._put(food)
		_client_transfer.rpc(player_id, food.name)


## Client-side method to transfer food, called by host
## @param player_id: The id of the player who is transferring the food
@rpc("authority", "call_remote", "reliable")
func _client_transfer(player_id: int, food_name: String) -> void:
	var player_cookware = GlobalScript.get_local_player_by_id(player_id).item_in_hand
	if player_cookware is Cookware and player_cookware._can_accept(supply_instance):
		var food = take()
		food.name = food_name
		player_cookware._put(food)


## Give visual feedback when hovered
## @param is_hovered: Whether the item is hovered or not
func _on_interactable_component_hovered(is_hovered: bool) -> void:
	if not is_hovered:
		highlight_component.hide_feedback()
		return
	var item = GlobalScript.get_local_player().item_in_hand
	
	#---------------------------------------------------------------------------
	if item:
		print("Player has : ", item.get_script().get_global_name(), ", hovered: ", get_script().get_global_name())
	#---------------------------------------------------------------------------
	if not item:
		highlight_component.show_feedback(true)
		return
	if item is Cookware:
		if item._can_accept(supply_instance):
			highlight_component.show_feedback(true)
		else:
			highlight_component.show_feedback(false)
#---------------------------------------------------------------------------------------------------


## Override unsupported methods to prevent misuse ------------------------------
func put(_item: Node) -> bool:
	assert(false, "Food Crate does not support putting items")
	return false

func take_at(_index: int) -> Node:
	assert(false, "Food Crate does not support taking items at specific index")
	return null

func start_action() -> bool:
	return false

func put_from_player(_item: Node) -> bool:
	assert(false, "Food Crate does not support putting items")
	return false
#-------------------------------------------------------------------------------


## Switches the current catergofy of the food crate
func _switch_catergory():
	_switched = true
	catergory = catergory + 1 if catergory < Catergory.size() - 1 else 0
	wait_timer.start()
	current_index = 0
	supply = FOOD_ORDER[catergory][current_index]
	
	print("SWITCHED TOO: ", catergory)
	_set_mesh()



## Sets up the timer for how long the player needs to wait
func _timer_setup():
	add_child(wait_timer)
	wait_timer.wait_time = wait_time
	wait_timer.autostart = false
	wait_timer.timeout.connect(_switch_catergory)


func _on_interactable_component_action_use(_is_action: bool) -> void:
	action_held = _is_action
	if _is_action: 
		wait_timer.start() #Starts timer to check if to switch catergory
		return
	
	wait_timer.stop()
	
	if(_switched): 
		_switched = false 
		return
	
	#Chnages the food within catergory
	var size : int = FOOD_ORDER[catergory].size()
	current_index = current_index + 1 if (current_index < size - 1) else 0
	supply = FOOD_ORDER[catergory][current_index]

func _set_mesh():
	$Fridge.visible = true if catergory == Catergory.FRIDGE else false
	$Crate.visible = true if catergory != Catergory.FRIDGE else false
	match catergory:
		Catergory.PANTRY:
			material.albedo_color = Color(Color.SADDLE_BROWN)
		Catergory.VEGE:
			material.albedo_color = Color(Color.WEB_GREEN)
		Catergory.FRUIT:
			material.albedo_color = Color(Color.CRIMSON)
		Catergory.FRIDGE:
			pass
	
	crate.set_surface_override_material(1, material)

@rpc("any_peer", "call_local")
func _destroy(item_path : String):
	var item = get_tree().current_scene.get_node(item_path)
	item.queue_free()
