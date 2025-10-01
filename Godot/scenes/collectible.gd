class_name Collectible
extends Node3D

signal collected(collectible : Collectible)

@onready var tween : Tween = get_tree().create_tween()

func _ready() -> void:
	var start_pos = position
	var end_pos = start_pos + Vector3(0,0.2,0) 
	_bobble(start_pos, end_pos)
	$Area3D.body_entered.connect(_entered)
	add_to_group("Collectible")
	
func _physics_process(delta: float) -> void:
	rotation.y +=  0.5 * delta


func _bobble(start_pos : Vector3, end_pos : Vector3):
	tween.tween_property(self, "position", end_pos, 1.5) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", start_pos, 1.5) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	tween.set_loops()


@rpc("any_peer", "call_local")
func _destroy():
	tween.stop()
	emit_signal("collected", self)
	self.queue_free()


func _entered(body : Node3D):
	if !ENetManager.is_host() || body is Player:
		print(body)
		return
	rpc("_destroy")
