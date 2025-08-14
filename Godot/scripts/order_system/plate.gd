##-----------------------------------------
## Temporary replace it to make it compile
## extends AbstractPickup
extends AbstractThrowable
##-----------------------------------------
class_name Plate
var preload_menuItems = preload("res://scripts/Food/MenuItems/menuItem.gd")


var food_items :Array = []
var has_menu_item: bool = false
#var ingredients = IngredientsEnum.Ingredients
#var dish = DishEnum.new()
var menu_instance
const GRID_SIZE = 3
const CELL_SIZE = 0.5
var grid: Array = []


func _ready():
	menu_instance = preload_menuItems.new()
	# Makes a grid on the plate in which ingredients can be placed in 
	grid.resize(GRID_SIZE)
	for i in range(GRID_SIZE):
		grid[i] = []
		grid[i].resize(GRID_SIZE)
		for j in range(GRID_SIZE):
			grid[i][j]=null # Makes sure they all start out null
	
	print(grid)


func find_next_free_cell() -> Vector2i:
	for i in range(grid.size()):
		for j in range(grid.size()):
			if grid[i][j] == null:
				return Vector2i(i,j)
	return Vector2i(-1,-1)

# Adds items to the plate and scales them so that they appear on the plate
func add_item(food_node) -> void:
	disable_collision(food_node)
	food_items.append(food_node)
	print("Ingredient on the plate: ", food_items)
	
	var cell = find_next_free_cell()
	if cell.x == -1:
		print("plate full")
		return
	
	grid[cell.x][cell.y] = food_node  # Note: using x for row, y for column
	food_node.get_parent().remove_child(food_node)
	add_child(food_node)
	
	food_node.scale = Vector3(0.15, 0.15, 0.15)
	
	# Center the grid on the plate
	# For a 3x3 grid, positions will be: -1, 0, 1 (multiplied by CELL_SIZE)
	var x_offset = (cell.x - 1) * CELL_SIZE  # cell.x - (GRID_SIZE-1)/2
	var z_offset = (cell.y - 1) * CELL_SIZE  # cell.y - (GRID_SIZE-1)/2
	
	# Position relative to the plate's center
	food_node.transform.origin = Vector3(x_offset, 0.2, z_offset)  # 0.2 = height above plate
	
	check_plate()

# This has been made so that we can add the different ingredients to the plate visually
func get_items():
	return food_items

# This is so that if they make a mistake they have to bin the whole thing
# We can change this later if you want them to be able to take off the top item
func remove_all():
	print("Removing all items from plate")
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			if grid[i][j] != null:
				var item = grid[i][j]
				if item.get_parent() == self:
					remove_child(item)
					item.free() 
			grid[i][j] = null
	food_items.clear()

# This checks if the plate contains a dish, when it does contain a dish it removes everything and
# replaces the list of ingredients with only the found meal
func check_plate():
	if food_items.is_empty():
		return 0
	var menuitem = menu_instance.match_menu_items(food_items)
	print("Menu item ==  ",menuitem)
	if menuitem != null:
		has_menu_item = true
		display_menu_item(menuitem)
		remove_all()
		grid[1][1] = menuitem # Makes the meal we created the only thing on the plate
	return 0


func display_menu_item(menuitem: MenuItem):
	# Load the actual scene file
	var scene_path = "res://scripts/Food/MenuItemScenes/" + menuitem.get_script().get_global_name() + ".tscn"
	var menu_scene = load(scene_path)
	if menu_scene:
		var menu_node = menu_scene.instantiate()
		add_child(menu_node)
		menu_node.transform.origin = Vector3(0, 0.2, 0)
		menu_node.scale = Vector3(0.25, 0.25, 0.25)
	else:
		print("Could not load scene for: ", menuitem.get_script().get_global_name())

# Function to set up the menu item's visual appearance
func setup_menu_item_appearance(menuitem: MenuItem):
	# You'll need to determine the quality/appearance based on your game logic
	# For now, let's assume we show the "good" version
	
	if menuitem.cooked_mesh_good != null:
		menuitem.cooked_mesh_good.visible = true
		
	if menuitem.cooked_mesh_bad != null:
		menuitem.cooked_mesh_bad.visible = false
		
	if menuitem.cooked_mesh_burnt != null:
		menuitem.cooked_mesh_burnt.visible = false


# Didnt work with the staticbody 3d as i couldnt get overlap checking to work with it
# I dont think Area3D has the same functionality as staticbody3d so Ive just made it so it turns off
# the collisions permenately
func turn_on_collision(turn_on: bool) -> void:
	#$Area3D.disabled = !turn_on
	$InteractableComponent/CollisionShape3D.disabled = !turn_on

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
func _on_interactable_component_action_use(is_action: bool) -> void:
	if not is_action:
		return
	
	var area = $Area3D
	for body in area.get_overlapping_bodies():
		if body.is_in_group("Food") && !has_menu_item:
			add_item(body) 
			break
		if body.is_in_group("Bin"):
			remove_all()
		if body is StaticBody3D:
			var food_node = body.get_parent()
			if food_node && food_node.is_in_group("Food") && !has_menu_item:
				add_item(food_node)
				break
			if food_node && food_node.is_in_group("Bin"):
				remove_all()
