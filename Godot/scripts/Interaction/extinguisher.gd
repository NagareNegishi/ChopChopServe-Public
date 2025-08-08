class_name Extinguisher extends AbstractPickup

## Called when the node enters the scene tree for the first time.
## @return void
func _ready() -> void:
	$ExtinguishRange.enabled = false
	$ExtinguishRange/GPUParticles3D.emitting = false


## Called every frame. 'delta' is the elapsed time since the previous frame.
## @param delta elapsed time since the previous frame
## @return void
func _physics_process(_delta: float) -> void:
	if !$ExtinguishRange.is_colliding():
		return
		
	_extingush()


## Will extingush the fire from appliance the line trace is hitting if valid
## @return void
func _extingush() -> void:
	if $ExtinguishRange.get_collider() is StaticBody3D:
		pass


## Overidden: Enables Extishuger line trace and foam if action is being used
## @param is_action if the player is using the action input
## @return void
func _on_interactable_component_action_use(is_action: bool) -> void:
	$ExtinguishRange.enabled = true if is_action else false
	$ExtinguishRange/GPUParticles3D.emitting = is_action
