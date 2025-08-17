class_name Fryer
extends PoweredAppliance

var inflammable_component: Inflammable

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/furniture/DeepFryer.glb")


## Setup the fryer properties
func _ready():
	super._ready()
	cooking_style = ApplianceFactory.CookingStyle.DEEP_FRY
	valid_classes = ["FryerBasket"] # Only one FryerBasket allowed
	capacity = 1
	power = 1
	add_cookware("fryer_basket")
	_setup_inflammable()
	# cook_interval = 1.0


## Override upgradable setup in concrete appliances
func _setup_upgradable():
	super._setup_upgradable()
	enable_upgrade("power", [1, 1, 1], [100, 200, 300])
	enable_upgrade("capacity", [1], [80])


## Setup inflammable component
func _setup_inflammable():
	inflammable_component = Inflammable.new()
	add_child(inflammable_component)