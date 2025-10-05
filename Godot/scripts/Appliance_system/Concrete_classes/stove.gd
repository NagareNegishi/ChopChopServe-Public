class_name Stove
extends PoweredAppliance

var inflammable_component: Inflammable

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/newmodels/furniture/StoveSingle.glb")
	appliance_name = "Stove"


## Setup the stove properties
func _ready():
	super._ready()
	cooking_style = ApplianceFactory.CookingStyle.BOIL
	valid_classes = ["Pot", "FryingPan"] # Only one Pot or FryingPan allowed
	capacity = 1
	power = 1
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
	var slot_position = Vector3(0.0, size.y * 0.8, 0.0)
	cookware_slots.append(slot_position)
