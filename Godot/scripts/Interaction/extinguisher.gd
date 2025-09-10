class_name Extinguisher extends AbstractThrowable

## Called when the node enters the scene tree for the first time.
## @return void
func _ready() -> void:
	$ExtinguishRange.enabled = false
	$ExtinguishRange/GPUParticles3D.emitting = false
	if !multiplayer.is_server():
		set_physics_process(false)



## Called every frame. 'delta' is the elapsed time since the previous frame.
## @param delta elapsed time since the previous frame
## @return void
func _physics_process(_delta: float) -> void:
	
	if  !_can_extingush():
		return
	
	_extingush()

func _can_extingush() -> bool:
	return (!$ExtinguishRange.is_colliding() && 
	$ExtinguishRange.get_collider() is Appliance)


## Will extingush the fire from appliance the line trace is hitting if valid
## @return void
func _extingush() -> void:
	var appliance : Appliance = $ExtinguishRange.get_collider()
	print("extingush needs to be implemented")


## Overidden: Enables Extishuger line trace and foam if action is being used
## @param is_action if the player is using the action input
## @return void
func _on_interactable_component_action_use(is_action: bool) -> void:
	rpc("server_action", is_action)


@rpc("authority", "call_local")
func server_action(is_action : bool):
	rpc("_client_action", is_action)
	

@rpc("any_peer", "call_local")
func _client_action(is_action : bool):
	$ExtinguishRange.enabled = true if is_action else false
	$ExtinguishRange/GPUParticles3D.emitting = is_action
