class_name Oven
extends PoweredAppliance

var inflammable_component: Inflammable

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/newmodels/furniture/Oven.glb")
	appliance_name = "Oven"

## Setup the oven properties
func _ready():
	super._ready()
	cooking_style = ApplianceFactory.CookingStyle.BAKE
	valid_classes = ["OvenTray"] # Only one OvenTray allowed
	capacity = 1
	power = 1
	_add_cookware("oven_tray")
	_setup_inflammable()
	# cook_interval = 1.0


## Override upgradable setup in concrete appliances
func _setup_upgradable():
	super._setup_upgradable()
	enable_upgrade("power", [1, 1, 1], [100, 200, 300])


## Setup inflammable component
func _setup_inflammable():
	inflammable_component = Inflammable.new()
	add_child(inflammable_component)
