class_name Extinguisher extends AbstractThrowable
@onready var tween : Tween = get_tree().create_tween()
## Called when the node enters the scene tree for the first time.
## @return void
func _ready() -> void:
	var start_pos = position
	var end_pos = start_pos + Vector3(0,0.2,0) 
	$ExtinguishRange.enabled = false
	$ExtinguishRange/GPUParticles3D.emitting = false
	_bobble(	start_pos, end_pos)
	#if !multiplayer.is_server():
		#set_physics_process(false)


func _bobble(start_pos : Vector3, end_pos : Vector3):
	tween.tween_property(self, "position", end_pos, 1.5) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", start_pos, 1.5) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	tween.set_loops()

## Called every frame. 'delta' is the elapsed time since the previous frame.
## @param delta elapsed time since the previous frame
## @return void
func _physics_process(_delta: float) -> void:
	rotation.y +=  0.5 * _delta
	
	if  !_can_extingush():
		return
	
	_extingush()

func _can_extingush() -> bool:
	return ($ExtinguishRange.is_colliding() && 
	$ExtinguishRange.get_collider() is Appliance)


## Will extingush the fire from appliance the line trace is hitting if valid
## @return void
func _extingush() -> void:
	
	var appliance : Appliance = $ExtinguishRange.get_collider()
	
	if (!"inflammable_component" in appliance): return

	var component : Inflammable = appliance.inflammable_component
	
	if component	.fire_level <= 0: return
	
	component.extinguish(1)



## Overidden: Enables Extishuger line trace and foam if action is being used
## @param is_action if the player is using the action input
## @return void
func _on_interactable_component_action_use(is_action: bool) -> void:

	$ExtinguishRange/GPUParticles3D.emitting = is_action
	$ExtinguishRange.enabled = true if is_action else false
