## ChoppingBoard is a type of Cookware that allows players to chop food items.
## Unlike other Cookware, it does not require any power source to operate.
## Chopping is triggered by player interaction.
## ChoppingBoard can only hold one food item at a time.
## ChoppingBoard can not be picked up, and always on ChopTable.
class_name ChoppingBoard
extends Cookware

var food_rotation = Vector3(0, 30, 0)


## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/newmodels/items/ChoppingBoardNoKnife.glb")


## Setup the fryer properties
func _ready():
	super._ready()
	interactable_component.is_pickup = false
	cooking_style = ApplianceFactory.CookingStyle.CHOP
	valid_food = ["Fish", "Tomato", "Potato", "Onion", "Cheese", "Apple", "Garlic", "Ham",
				"Mushroom", "Pineapple", "Pumpkin", "Strawberry"]
	capacity = 1 # one item only
	coefficient = 1.0
	add_to_group("Appliance")


## Add interactable component to this class
## InteractableComponent is scene dependent, can not instantiate from script
func _setup_interactable():
	super._setup_interactable()
	interactable_component.has_action = true


## Set the rotation for food placed on the chopping board
func set_food_rotation(angle: Vector3) -> void:
	food_rotation = angle


## Place an item onto this appliance
## @param item: The Node to place on this appliance
## @return: True if placement was successful, false otherwise
func put(item: Node) -> bool:
	if not _can_accept(item):
		return false
	contents.append(item)
	add_child(item)
	item.position = Vector3(0.0, size.y * 0.5, 0.0)
	return true


## Place food into the cookware
## @param food: The Food item to place into the cookware
func _put_food(food: Food) -> void:
	food.change_collisions(true)
	food.restore_original_transform()
	food.rotate_abstract_throwable(food_rotation)
	emit_signal("food_placed", self, contents)
	Debug.cook_log("Food placed in cookware: " + food.get_script().get_global_name()
		+ ", Cookware can cook: " + str(can_cook()) + ", Food cook time: " + str(food.get_cook_time(cooking_style)))


## Perform cooking logic
## @param power: The power from PoweredAppliance
func cook(power: int) -> bool:
	for food in contents:
		food.start_cooking(int(power * coefficient), cooking_style)
	return true


## Remove and return all items
## @return: Array of all items that were removed
func take_all() -> Array[Node]:
	finish_cook()
	var all_items = contents
	for item in all_items:
		remove_child(item)
	contents = []
	contents_names = []
	emit_signal("food_taken", self, contents)
	return all_items


## Setup the cookware UI
func _setup_cookware_ui():
	return # Chopping board does not need UI


## For Player interaction --------------------------------------------------------------------------

## Place an item onto this appliance
## @param item: The Node to place on this appliance
## @return: True if placement was successful, false otherwise
func put_from_player(item: Node) -> bool:
	if not _can_accept(item):
		return false
	# transfer item to appliance
	GlobalScript.get_local_player().remove_item()
	contents.append(item)
	add_child(item)
	item.position = Vector3(0.0, size.y * 0.5, 0.0)
	Debug.all("Put: " + item.get_script().get_global_name() + " onto: " + get_script().get_global_name())
	return true


## Trigger action, if subclass has action
func _on_interactable_component_action_use(_is_action: bool) -> void:
	if _is_action:
		cook(1)
	else:
		finish_cook()
#---------------------------------------------------------------------------------------------------
