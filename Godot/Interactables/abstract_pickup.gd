class_name AbstractPickup extends Node3D

@export var has_action : bool


## Called when the node enters the scene tree for the first time.
## @return void
func _ready() -> void:
	pass # Replace with function body.


## Called every frame. 'delta' is the elapsed time since the previous frame.
## @param delta elapsed time since the previous frame
## @return void
func _process(_delta: float) -> void:
	pass


## Connect to singal: Called when interacted with and will make the player pick this item up
## @return void
func _on_interactable_component_interacted() -> void:
	GlobalScript.player.pickup_item(self)
	print("Pickup: Interacted")


## Allows to turn on & off the collision box for interaction events
## @param turn_on boolean the sets the collsion on or off
## @return void
func turn_on_collision(turn_on: bool) -> void:
	$StaticBody3D/CollisionShape3D.disabled = !turn_on
	$InteractableComponent/CollisionShape3D.disabled = !turn_on


## Connected to signal: Called when pickup is being hovered or unhovered
## @param is_hovered boolean that dicates if pickup is on or off
## @return void
func _on_interactable_component_hovered(is_hovered: bool) -> void:
	if is_hovered:
		print("Hovered: " + str(self))

## Connected to signal: Called when player does action with this item in hand
## @param has_action if the player is using the action input
## @return void
func _on_interactable_component_action_use(is_action: bool) -> void:
	if has_action:
		print("Action: " + str(is_action))
