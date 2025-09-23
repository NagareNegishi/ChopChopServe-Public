class_name UpgradeHammer extends AbstractThrowable

@onready var interact_comp : InteractableComponent = $InteractableComponent


func _ready() -> void:
	interact_comp.local_action_use.connect(_can_upgrade)

	
func _can_upgrade(is_action : bool):
	var appliance : Appliance = GlobalScript.get_local_player()._closest_item.get_parent() 
	
	if appliance == null || !(appliance is Appliance): return
	
	if !_can_purchase(appliance) :  return
	
	#appliance.capacity_upgradable.request_upgrade(ENetManager.get_my_id())
	#appliance.power_upgradable.request_upgrade(ENetManager.get_my_id())
	#appliance.coefficient_upgradable.request_upgrade(ENetManager.get_my_id())
	
	GlobalScript.get_local_player().anim_tree["parameters/SM_ACTION/conditions/whacking"] = true
	print("Upgrade")

func _can_purchase(appliance : Appliance) -> bool:
	return CurrencySystem.check_currency(ENetManager.get_my_team(), 200) 
