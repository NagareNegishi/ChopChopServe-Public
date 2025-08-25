## ChopTable is a type of Bench with a built-in ChoppingBoard.
## ChopTable allows players to place items on the chopping board
## and perform chopping actions.
class_name ChopTable
extends Bench

var chopping_board: ChoppingBoard

## Setup the bench
func _ready():
	super._ready()
	_add_chopping_board()


## Add interactable component to this class
## InteractableComponent is scene dependent, can not instantiate from script
func _setup_interactable():
	super._setup_interactable()
	interactable_component.has_action = true


## Add the chopping board to the bench
func _add_chopping_board() -> void:
	capacity = 1
	item_slots.clear()
	chopping_board = ApplianceManager.request_appliance("chopping_board", current_owner)
	add_child(chopping_board)
	var board_position = Vector3(0.0, size.y * 0.5, 0.0)
	chopping_board.position = board_position
	chopping_board.lock()
	chopping_board._toggle_interaction(false)


## Place an item onto this appliance
## @param item: The Node to place on this appliance
## @return: True if placement was successful, false otherwise
func put(item: Node) -> bool:
	if not _can_accept(item):
		return false
	return chopping_board.put(item)


## Remove and return the last item from this appliance
## @return: The Node that was removed, or null if nothing to take
func take() -> Node:
	return chopping_board.take()


## Check if this appliance can accept the given item
## @param item: The Node to test for acceptance
## @return: True if item can be placed, false otherwise
func _can_accept(item: Node) -> bool:
	return chopping_board._can_accept(item)


## Handle fire event
func on_fire() -> void:
	current_status = Status.UNABLE
	var all_items = chopping_board.take_all()
	for item in all_items:
		item.queue_free()


## Perform action depend on what player is holding
## @param _item: The Node Player is holding
## @return: True if action is triggered, false otherwise
func player_has(item: Node) -> bool:
	if item:
		if chopping_board.put(item):
			print("Place :", item.get_script().get_global_name(), " onto chopping board")
			return true
		print("Chopping board cannot accept:", item.get_script().get_global_name())
		return false
	#------------------------------------------------------------------------------------
	# let player pick up directly??
	GlobalScript.player.pickup_item(chopping_board.take())
	#------------------------------------------------------------------------------------
	return true


## Trigger action, if subclass has action
func _on_interactable_component_action_use(_is_action: bool) -> void:
	if _is_action:
		chopping_board.cook(1)
	else:
		chopping_board.finish_cook()



## Override unsupported methods to prevent misuse ------------------------------
func take_at(_index: int) -> Node:
	assert(false, "ChopTable does not support take_at")
	return null

func take_food() -> Food:
	assert(false, "ChopTable does not support take_food")
	return null
#-------------------------------------------------------------------------------