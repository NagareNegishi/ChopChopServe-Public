class_name Present extends AbstractThrowable

signal purchase()

@onready var interact_timer : Timer = Timer.new()
@onready var interact_component : InteractableComponent = $InteractableComponent
@onready var details_ui : UIPresent = $Price/SubViewport/UiPresent
@onready var mesh : MeshInstance3D = $MeshInstance3D

@export var class_script : GDScript

var colours = {
	0 : Color("9e9291"),
	1 : Color("ff4b2b"),
	2 : Color("f8ff33")
}

var progress_amount : float
var team : int
var _can_buy : bool = false


func _ready() -> void:
	interact_component.action_use.connect(_on_interactable_component_action_use)
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


func set_appliance(script : GDScript):
	class_script = script
	

func _local_action(is_action : bool):
	team = ENetManager.get_my_team() if is_action else 0
	_can_buy = CurrencySystem.check_currency(team, 200)
	if is_action:
		purchase.connect(_remove_money)
	else:
		purchase.disconnect(_remove_money)
	
func _on_interactable_component_action_use(is_action: bool) -> void:
	if is_action:
		interact_timer.start()
	
	progress_amount = 0.01 if is_action else -0.0025


func _timeout():
	details_ui.add_progress(progress_amount)
	
	if details_ui.progress_bar.value >= 1:
		interact_timer.stop()
		details_ui.visible = false;
		emit_signal("purchase")
		set_can_interact()
		
		
	elif details_ui.progress_bar.value <= 0:
		interact_timer.stop()


func set_can_interact():
	if ENetManager.get_my_team() == team:
		interact_component.can_be_interacted = true
	set_colour(colours[team])


func _remove_money():
	CurrencySystem.minus_currency(team, class_script.price);
	pass
