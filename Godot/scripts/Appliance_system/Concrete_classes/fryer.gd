class_name Fryer
extends PoweredAppliance

var inflammable_component: Inflammable
## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/newmodels/furniture/DeepestFryer.glb")


## Setup the fryer properties
func _ready():
	super._ready()
	cooking_style = ApplianceFactory.CookingStyle.DEEP_FRY
	valid_classes = ["FryerBasket"] # Only one FryerBasket allowed
	capacity = 1
	power = 1
	_add_cookware("fryer_basket")
	_setup_inflammable()


## Override upgradable setup in concrete appliances
func _setup_upgradable():
	super._setup_upgradable()
	enable_upgrade("power", [1, 1, 1], [100, 200, 300])


## Setup inflammable component
func _setup_inflammable():
	inflammable_component = Inflammable.new()
	add_child(inflammable_component)


## Setup cookware slots, should be overridden by subclasses
## Default implementation expect one Cookware slot in the center
func _setup_cookware_slots():
	var slot_position = Vector3(size.x * -0.2, size.y * 0.4, size.z * -0.2)
	cookware_slots.append(slot_position)
