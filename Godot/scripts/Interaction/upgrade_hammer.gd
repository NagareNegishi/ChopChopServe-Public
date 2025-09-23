class_name UpgradeHammer extends AbstractThrowable

@onready var interact_comp : InteractableComponent = $InteractableComponent
@onready var player : Player = GlobalScript.get_local_player()

func _ready() -> void:
	interact_comp.local_action_use.connect(_can_upgrade)

	
func _can_upgrade(is_action : bool):
	if GlobalScript.get_local_player()._closest_item == null : return
	var appliance : Appliance = GlobalScript.get_local_player()._closest_item.get_parent() 
	
	if appliance == null || !(appliance is Appliance): return
	
	if !_can_purchase(appliance) :  return
	
	_animation()
	_upgrade()
	
	

func _can_purchase(appliance : Appliance) -> bool:
	return CurrencySystem.check_currency(ENetManager.get_my_team(), 200) 

func _animation():
	player.anim_tree["parameters/conditions/action"] = true
	player.anim_tree["parameters/conditions/unaction"] = false
	player.anim_tree["parameters/SM_ACTION/conditions/whacking"] = true
	player.disable_controls(true)
	player.item_in_hand.visible = false
	
	await get_tree().create_timer(1.2).timeout

	player.disable_controls(false)
	player.item_in_hand.visible = true
	player.anim_tree["parameters/SM_ACTION/conditions/whacking"] = false
	player.anim_tree["parameters/conditions/unaction"] = true
	player.anim_tree["parameters/conditions/action"] = false


func _upgrade():
	pass
