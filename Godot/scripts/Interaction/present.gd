class_name Present extends AbstractThrowable

signal purchase()

@onready var interact_timer : Timer = Timer.new()
@onready var interact_component : InteractableComponent = $InteractableComponent
@onready var details_ui : UIPresent = $Price/SubViewport/UiPresent
@onready var mesh : MeshInstance3D = $MeshInstance3D

@export var type : ApplianceType

enum ApplianceType{
	BENCH,
	CHOP
}

var colours = {
	0 : Color("9e9291"),
	1 : Color("ff4b2b"),
	2 : Color("f8ff33")
}

var progress_amount : float
var team : int
var _can_buy : bool = true
var brought = false


func _ready() -> void:
	interact_component.local_action_use.connect(_local_action)
	interact_component.can_be_interacted = false
	
	add_child(interact_timer)
	interact_timer.wait_time = 0.01
	interact_timer.autostart = false
	interact_timer.timeout.connect(_timeout)
	
	
	set_colour(colours[0])


func set_colour(c : Color):
	var material : Material = StandardMaterial3D.new() 
	material.albedo_color = c
	mesh.set_surface_override_material(1, material)
	

func _local_action(is_action : bool):
	team = ENetManager.get_my_team() if is_action else 0
	if team == 0 : return
	
	_can_buy = CurrencySystem.check_currency(team, 200)
	
	if is_action && !purchase.is_connected(_remove_money):
		purchase.connect(_remove_money)
	
	elif purchase.is_connected(_remove_money):
		purchase.disconnect(_remove_money)
	
	if is_action && brought && GlobalScript.get_local_player().item_in_hand is Present:
		get_tree().call_group("BuildCube", "place_building") 
		GlobalScript.get_local_player().rpc_id(1, "server_drop_item", GlobalScript.get_local_player().get_path(), false)
		rpc("_destroy")


func _on_interactable_component_action_use(is_action: bool) -> void:
	if is_action && !brought:
		interact_timer.start()
	
	progress_amount = 0.01 if is_action else -0.0025


func _timeout():
	details_ui.add_progress(progress_amount)
	
	if details_ui.progress_bar.value >= 1:
		interact_timer.stop()
		details_ui.visible = false;
		brought = true
		emit_signal("purchase")
		set_can_interact()
		
		
	elif details_ui.progress_bar.value <= 0:
		interact_timer.stop()


func set_can_interact():
	if ENetManager.get_my_team() == team:
		interact_component.can_be_interacted = true
	set_colour(colours[team])


func _remove_money():
	CurrencySystem.minus_currency(team, 200);
	print("brought")
	pass

@rpc("any_peer","call_local")
func _destroy():
	queue_free()
