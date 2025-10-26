extends AbstractThrowable
class_name Plate
var preload_menuItems = preload("res://scripts/Food/MenuItems/menuItem.gd")


# TODO: Add a plate is ready method as plate needs to be clean and empty 

var food_items :Array = []
var has_menu_item: bool = false
var quality_on_plate: Array = []
var floor_time_count = 0
#var ingredients = IngredientsEnum.Ingredients
#var dish = DishEnum.new()
var menu_instance
var quality
const GRID_SIZE = 3
const CELL_SIZE = 0.2
var grid: Array = []
@export var is_dirty : bool = false
var is_full : bool = false
var number: int = 0
var plate_owner : int = 1
var clean_level = 0
var recipe_on_plate = null
var current_mesh : MeshInstance3D
@onready var clean_mesh: MeshInstance3D = $PlateMesh
@onready var dirty_mesh: MeshInstance3D = $platedirt

func _ready():
	set_plate_mesh()
	menu_instance = preload_menuItems.new()
	#print(menu_instance)
	# Makes a grid on the plate in which ingredients can be placed in 
	grid.resize(GRID_SIZE)
	for i in range(GRID_SIZE):
		grid[i] = []
		grid[i].resize(GRID_SIZE)
		for j in range(GRID_SIZE):
			grid[i][j]=null # Makes sure they all start out null
	freeze = true

func _set_owner(id : int):
	await get_tree().create_timer(0.1).timeout
	_server_set_owner.rpc(1 if ENetManager.get_team1().has(id) else 2)

@rpc("any_peer", "call_local")
func _server_set_owner(team : int):
	plate_owner = team
	print(plate_owner)


func get_clean_level():
	return clean_level

func set_clean_level(value: int):
	clean_level = value

func find_next_free_cell() -> Vector2i:
	for i in range(grid.size()):
		for j in range(grid.size()):
			if grid[i][j] == null:
				return Vector2i(i,j)
	return Vector2i(-1,-1)

# Adds items to the plate and scales them so that they appear on the plate
func add_list_items(food_array: Array):
	add_item(food_array.duplicate())

func add_item(food_node) -> void:
	#print("Adding item to plate: ", food_node, ", food_name: ", food_node.food_name)
	var cell = find_next_free_cell()
	if food_node is Array:
		food_items.append_array(food_node)
		for item in food_node:
			disable_collision(item)
			quality_on_plate.append(item.get_quality())
			floor_time_count += item.get_floor_time()
			if cell.x == -1:
				#print("plate full")
				return
			grid[cell.x][cell.y] = item
			if item.get_parent():
				item.get_parent().remove_child(item)
			add_child(item)
			
			# Disable physics for items
			if item is RigidBody3D:
				item.freeze = true
				item.gravity_scale = 0
			
			item.scale = Vector3(0.5, 0.5, 0.5)
			
			var x_offset = (cell.x - 1) * CELL_SIZE
			var z_offset = (cell.y - 1) * CELL_SIZE
			
			# Try positioning at the plate's center first
			item.transform.origin = Vector3(x_offset, 0.05, z_offset)
	else:
		food_items.append(food_node)
		disable_collision(food_node)
		quality_on_plate.append(food_node.get_quality())
		floor_time_count += food_node.get_floor_time()
		if food_node.get_parent():
			food_node.get_parent().remove_child(food_node)
		add_child(food_node)
		# Disable physics for items
		if food_node is RigidBody3D:
			food_node.freeze = true
			food_node.gravity_scale = 0
		
		food_node.scale = Vector3(0.5, 0.5, 0.5)
		
		var x_offset = (cell.x - 1) * CELL_SIZE
		var z_offset = (cell.y - 1) * CELL_SIZE
		
		# Try positioning at the plate's center first
		food_node.transform.origin = Vector3(x_offset, 0.05, z_offset)
	
	
	check_plate.rpc()

# This has been made so that we can add the different ingredients to the plate visually
func get_items():
	return food_items

# This is so that if they make a mistake they have to bin the whole thing
# We can change this later if you want them to be able to take off the top item
func remove_all():
	if recipe_on_plate != null and is_instance_valid(recipe_on_plate):
		if recipe_on_plate.get_parent() == self:
			remove_child(recipe_on_plate)
		recipe_on_plate.queue_free()
		recipe_on_plate = null
	
	if food_items is Array and not food_items.is_empty():
		for item in food_items:
			if is_instance_valid(item):
				if item.get_parent() == self:
					remove_child(item)
				item.queue_free()
		food_items.clear()
	
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			if grid[i][j] != null:
				var item = grid[i][j]
				if is_instance_valid(item):
					if item.get_parent() == self:
						remove_child(item)
					item.queue_free()
			grid[i][j] = null
	
	has_menu_item = false
	is_full = false
	quality_on_plate.clear()
	floor_time_count = 0




func give_all()->Array:
	var food_list = food_items
	remove_all()
	return food_list

# This checks if the plate contains a dish, when it does contain a dish it removes everything and
# replaces the list of ingredients with only the found meal
@rpc("any_peer","call_local","reliable")
func check_plate():
	if food_items.is_empty():
		return
	
	var menuitem = menu_instance.match_menu_items(food_items.duplicate())
	
	if menuitem != null:
		has_menu_item = true
		_set_quality(quality_on_plate)
		display_menu_item(menuitem)
		menuitem.set_quality(quality)
		is_full = true
		
		for item in food_items:
			if is_instance_valid(item):
				if item.get_parent() == self:
					remove_child(item)
				item.queue_free()
		food_items.clear()
	
		for i in range(GRID_SIZE):
			for j in range(GRID_SIZE):
				grid[i][j] = null
		grid[1][1] = recipe_on_plate

	print("MENU ITEM ISSSSS: ", menuitem, " therefore recipe on plate ", recipe_on_plate)


func _set_quality(list: Array):
	if list.size()<=0:
		push_error("Nothing in list")
	
	for elem in list:
		#print("NUMBER: ",number)
		#print("ELEM: ", elem)
		number = number + elem
	
	@warning_ignore("integer_division")
	var average_quality = number / list.size()
	
	quality = (average_quality - floor_time_count)
	# Make sure its not negative
	if quality < 0:
		quality = 0
	
	#print("QUALITY: ", quality, "TIMES FLOOR TOUCHED: ", floor_time_count)

func get_quality():
	return quality

func display_menu_item(menuitem: MenuItem):
	var scene_path = "res://scripts/Food/MenuItemScenes/" + menuitem.get_script().get_global_name() + ".tscn"
	var menu_scene = load(scene_path)
	if menu_scene:
		var menu_node = menu_scene.instantiate()
		add_child(menu_node)
		set_mesh(menu_node)
		menu_node.transform.origin = Vector3(0, 0.05, 0)
		menu_node.scale = Vector3(0.7, 0.7, 0.7)
		
		recipe_on_plate = menu_node
	else:
		push_error("Could not load scene for: ", menuitem.get_script().get_global_name())

# Makes it so when the player picks up the ingredient its collisions
# dont stop it from moving correctly which is what the function above is supposed to do
# but that doesnt work with an area3d for some reason
func disable_collision(node: Node):
	var collision_shapes = node.get_children()
	for child in collision_shapes:
		if child is CollisionShape3D:
			child.disabled = true
		elif child.get_child_count() > 0:
			disable_collision(child) # recursively disable in children


# this is what the plate does when in certain areas, Havent added what it is to do when it interacts
# with the appliance yet but shouldnt be too difficult
func _on_interactable_component_action_interact(is_action: bool) -> void:
	if not is_action:
		return
	
	var area = $Area3D
	for body in area.get_overlapping_bodies():
		
		# Check if interacting with Equipment/Appliance while player is holding the plate
		if body is Equipment or body.get_parent() is Equipment:
			var equipment = body if body is Equipment else body.get_parent()
			
			# Only transfer if plate has food items and player is holding the plate
			if not food_items.is_empty() and GlobalScript.player.item_in_hand == self:
				var food_list = give_all()
				
				# Try to add each food item to the equipment
				for food_item in food_list:
					if not equipment.put(food_item):
						# If equipment can't accept the item, handle appropriately
						# Could put it back on plate, drop it, or show message
						push_error("Equipment couldn't accept: ", food_item.get_script().get_global_name())
				
				#print("Transferred items from plate to ", equipment.get_script().get_global_name())
				return
		
		# Original food pickup logic
		if body.is_in_group("Food") && !has_menu_item:
			add_item(body) 
			break
			
		# Bin interaction

			
		if body is StaticBody3D:
			var food_node = body.get_parent()
			if food_node && food_node.is_in_group("Food") && !has_menu_item:
				add_item(food_node)
				break
			if food_node && food_node.is_in_group("Bin"):
				remove_all()


func is_ready()->bool:
	if is_dirty:
		return false
	if is_full:
		return false
	
	return true

func set_mesh(food):
	food.mesh_visibility(food.cooked_mesh_good, false)
	food.mesh_visibility(food.cooked_mesh_bad, false)
	food.mesh_visibility(food.cooked_mesh_burnt, false)
	if quality >= 50:
		food.mesh_visibility(food.cooked_mesh_good, true)
	elif quality >= 10:
		food.mesh_visibility(food.cooked_mesh_bad, true)
	else:
		food.mesh_visibility(food.cooked_mesh_burnt, true)


func set_plate_mesh():
	dirty_mesh.visible = false
	clean_mesh.visible = false
	if is_dirty:
		current_mesh = dirty_mesh
	else:
		current_mesh = clean_mesh
	
	current_mesh.visible = true

## Functions for cleaning the plate --------------------------------------------

var dirtiness = 0
const MAX_DIRTINESS = 3

## Set the plate dirty or clean
## @param state: True if dirty, false if clean
func set_dirty(state: bool):
	is_dirty = state
	set_plate_mesh()
	if state:
		dirtiness = MAX_DIRTINESS
		clean_level = 0
	else:
		dirtiness = 0
		Debug.cook_log("Plate " + name + " is now clean")



## Clean the plate by reducing its dirtiness level
func clean():
	if not is_dirty:
		return
	set_dirty(false)


## Check if the plate is empty
## @return: True if empty, false otherwise
func is_empty() -> bool:
	return !is_full and food_items.is_empty()
