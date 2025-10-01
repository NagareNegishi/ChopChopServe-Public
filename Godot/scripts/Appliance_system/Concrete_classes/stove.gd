class_name Stove
extends PoweredAppliance

var inflammable_component: Inflammable

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/newmodels/furniture/Stove2.glb")


## Setup the stove properties
func _ready():
	super._ready()
	cooking_style = ApplianceFactory.CookingStyle.BOIL
	valid_classes = ["Pot", "FryingPan"] # Only one Pot or FryingPan allowed
	capacity = 1
	power = 1
	# cook_interval = 1.0
	_setup_inflammable()


## Override upgradable setup in concrete appliances
func _setup_upgradable():
	super._setup_upgradable()
	enable_upgrade("power", [1, 1, 1], [100, 200, 300])


## Setup inflammable component
func _setup_inflammable():
	inflammable_component = Inflammable.new()
	add_child(inflammable_component)
