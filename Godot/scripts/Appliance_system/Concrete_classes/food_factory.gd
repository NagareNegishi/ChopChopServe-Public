## FoodFactory provides all types of ingredient, but takes nothing back.
class_name FoodFactory
extends UnPoweredAppliance

const FOOD_DIRECTORY: String = "res://scripts/Food/IngredientScenes/"
static var food_book: Dictionary = {} # {name: PackedScene}
static var food_instances: Dictionary = {} # {name: instance}
static var registered: bool = false

@onready var inventory_scene = preload("res://FridgeInven/inven.tscn")
@onready var inventory_sprite : Inven = inventory_scene.instantiate()
@onready var marker : Marker3D = $CrateFoodMarker
@onready var material : Material = StandardMaterial3D.new()
@onready var crate : MeshInstance3D = $Crate

@export var group : Groups

var food_crate_visual = null

enum Groups{
	ONE,
	TWO,
	THREE,
	FOUR
}



## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/newmodels/furniture/Fridge.glb")
	if not registered:
		_register_foods()
		registered = true


## Set up the FoodCrate
func _ready():
	super._ready()
	action_interval = 0.5
	_set_affixes()
	_add_inventory_ui()
	interactable_component.has_action = true
	interactable_component.can_be_interacted = true
	_set_food_visual(inventory_sprite.inventory.get_current_slot().inventory_item_name)
	_set_colour()


## Register all foods from the directory
static func _register_foods() -> void:
	var dir = DirAccess.open(FOOD_DIRECTORY)
	if not dir:
		push_error("Cannot open food directory: " + FOOD_DIRECTORY)
		return
	# Iterate through all files in the directory
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tscn"):
			var food_name = file_name.get_basename()
			var scene_path = FOOD_DIRECTORY + file_name
			# Try to load the scene
			var food_scene = load(scene_path) as PackedScene
			if food_scene and food_scene.can_instantiate():
				# Store in registry
				food_book[food_name] = food_scene
				var sample = food_scene.instantiate()
				food_instances[food_name] = sample
			else:
				push_warning("Failed to load food scene: " + scene_path)
		file_name = dir.get_next()
	dir.list_dir_end()


## Create a food instance by name
func _create_food(food_name: String) -> Node:
	if not food_name in food_book:
		push_error("Food not found in registry: " + food_name)
		return null
	var food_scene = food_book[food_name] as PackedScene
	var food = food_scene.instantiate()
	food.name = prefix + food_name + str(supply_count)
	supply_count += 1
	return food


## Provide specific food from storage
func provide_food(food_name: String) -> Node:
	if current_status != Status.IDLE:
		push_error("FoodStorage is not in IDLE status")
		return null
	current_status = Status.USING
	action_timer.start()
	return _create_food(food_name)


## For Inventory UI --------------------------------------------------------------------------------

## Add inventory UI to the scene
var inventory : Inven

func _add_inventory_ui():
	inventory_sprite.name = "Inventory"
	inventory_sprite
	inventory_sprite.get_node("SubViewport").get_node("Inventory").group = group
	add_child(inventory_sprite)
	inventory = inventory_sprite
	inventory_sprite.no_depth_test = true
	inventory_sprite.position -= Vector3(0,2,0)


var player 
var is_open


## Handle food selection from inventory UI
## @param food_name: The name of the food selected
func _on_food_selected(food_name: String):
	var player = GlobalScript.get_local_player()
	if not player:
		return
	player_selected(player.item_in_hand, food_name)


## For Player interaction --------------------------------------------------------------------------

## Perform action depend on what player is holding
## @param _item: The Node Player is holding
## @param index: The index of the food item to take
## @return: True if action is triggered, false otherwise
func player_selected(item: Node, food_name: String) -> void:
	if not food_name in food_book:
		print("Unknown food: " + food_name)
		print("Known foods: ", food_book.keys())
		return
	if not item:
		provide_request(food_name)
		return
	if item is Cookware and item._can_accept(food_instances.get(food_name)):
		transfer_request(item, food_name)
		return


## Client-side method to take item, called by host
## @param item_name: The name of the item to take
@rpc("authority", "call_remote", "reliable")
func _client_provide(item_name: String, food_name: String) -> void:
	var item = provide_food(food_name)
	if not item:
		push_error("Failed to provide food: " + food_name)
		return
	item.name = item_name
	get_tree().current_scene.add_child(item)


## Request to take an item from this appliance to Player
func provide_request(food_name: String) -> void:
	_provide_as_host.rpc_id(1, ENetManager.get_my_id(), food_name)


## Host-side method to handle take requests from clients
## @param player_id: The id of the player who is taking the item
@rpc("any_peer", "call_local", "reliable")
func _provide_as_host(player_id: int, food_name: String) -> void:
	if not ENetManager.is_host():
		return
	# host need check to prevent conflicts/ cheating
	var item = provide_food(food_name)
	get_tree().current_scene.add_child(item)
	_client_provide.rpc(item.name, food_name)
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
			player.pickup_item(item)


## Transfer food from FoodCrate to Cookware
## @param cookware: The Cookware to transfer food to
func transfer_request(player_cookware: Cookware, food_name: String) -> void:
	var food = provide_food(food_name)
	if not food:
		return
	if ENetManager.is_host():
		player_cookware._put(food)
		_client_transfer.rpc(ENetManager.get_my_id(), food.name, food_name)
		return
	_transfer_as_host.rpc_id(1, ENetManager.get_my_id(), food_name)


## Host-side method to handle transfer requests from clients
## @param player_id: The id of the player who is transferring the food
@rpc("any_peer", "call_remote", "reliable")
func _transfer_as_host(player_id: int, food_name: String) -> void:
	if not ENetManager.is_host():
		return
	var player_cookware = GlobalScript.get_local_player_by_id(player_id).item_in_hand
	if player_cookware is Cookware and player_cookware._can_accept(food_instances.get(food_name)):
		var food = provide_food(food_name)
		player_cookware._put(food)
		_client_transfer.rpc(player_id, food.name, food_name)


## Client-side method to transfer food, called by host
## @param player_id: The id of the player who is transferring the food
@rpc("authority", "call_remote", "reliable")
func _client_transfer(player_id: int, item_name: String, food_name: String) -> void:
	var player_cookware = GlobalScript.get_local_player_by_id(player_id).item_in_hand
	if player_cookware is Cookware and player_cookware._can_accept(food_instances.get(food_name)):
		var food = provide_food(food_name)
		food.name = item_name
		player_cookware._put(food)


## Give visual feedback when hovered
## @param is_hovered: Whether the item is hovered or not
func _on_interactable_component_hovered(is_hovered: bool) -> void:
	if is_hovered && inventory: 
		inventory.get_node("SubViewport").get_node("Inventory").open()
	elif !is_hovered && inventory: 
		inventory.get_node("SubViewport").get_node("Inventory").close()
		
	if not is_hovered:
		highlight_component.hide_feedback()
		return
		
	var item = GlobalScript.get_local_player().item_in_hand
	
	if not item:
		highlight_component.show_feedback(true)
		return
		
	if item is not Cookware:
		return
		
	if item.is_full():
		highlight_component.show_feedback(false)
	else:
		highlight_component.show_feedback(true)

func _on_interactable_component_action_use(_is_action: bool) -> void:
	if !_is_action: return
	inventory_sprite.inventory.current_slot = inventory_sprite.inventory.move_forward()
	inventory_sprite.inventory.update_slot_selected(true)
	_set_food_visual(inventory_sprite.inventory.get_current_slot().inventory_item_name)


## Override unsupported methods to prevent misuse ------------------------------
func put(_item: Node) -> bool:
	assert(false, "Food Crate does not support putting items")
	return false

func take() -> Node:
	assert(false, "MultiFoodCrate requires an index to take specific food item")
	return null

func player_has(_item: Node) -> void:
	inventory_sprite.inventory.select_ingredient()
	return

func put_from_player(_item: Node) -> bool:
	assert(false, "Food Crate does not support putting items")
	return false
#-------------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("LB"):
		inventory_sprite.inventory.current_slot = inventory_sprite.inventory.move_backward()
		inventory_sprite.inventory.update_slot_selected(true)
	if Input.is_action_just_pressed("RB"):
		inventory_sprite.inventory.current_slot = inventory_sprite.inventory.move_forward()
		inventory_sprite.inventory.update_slot_selected(true)

func _set_food_visual(food : String):
	if food_crate_visual:
			marker.remove_child(food_crate_visual)
			food_crate_visual.queue_free()
	
	var scene = load("res://CrateScenes/" + food + ".tscn")
	if !scene: return
	food_crate_visual = scene.instantiate()
	marker.add_child(food_crate_visual)


func _set_colour():
	match group:
		Groups.ONE:
			material.albedo_color = Color(Color.ROYAL_BLUE)

		Groups.TWO:
			material.albedo_color = Color(Color.PALE_GOLDENROD)

		Groups.THREE:
			material.albedo_color = Color(Color.CRIMSON)

		Groups.FOUR:
			material.albedo_color = Color(Color.WEB_GREEN)
	
	crate.set_surface_override_material(1, material)
