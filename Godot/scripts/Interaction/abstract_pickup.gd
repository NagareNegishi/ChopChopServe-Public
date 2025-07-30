class_name AbstractPickup extends RigidBody3D

@export var has_action : bool


## Called when the node enters the scene tree for the first time.
## @return void
func _ready() -> void:
	pass


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
	$CollisionShape3D.disabled = !turn_on
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
	
func turnOnPhysics(is_on : bool):
	set_deferred("freeze", !is_on)
