class_name Oven
extends PoweredAppliance

var inflammable_component: Inflammable

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/furniture/Oven.glb")


## Setup the oven properties
func _ready():
	super._ready()
	cooking_style = ApplianceFactory.CookingStyle.BAKE
	valid_classes = ["OvenTray"] # Only one OvenTray allowed
	capacity = 1
	power = 1
	add_cookware("oven_tray")
	_setup_inflammable()
	# cook_interval = 1.0


## Override upgradable setup in concrete appliances
func _setup_upgradable():
	super._setup_upgradable()
	enable_upgrade("power", [1, 1, 1], [100, 200, 300])
	enable_upgrade("capacity", [1, 1, 1], [80, 160, 240])


## Setup inflammable component
func _setup_inflammable():
	inflammable_component = Inflammable.new()
	add_child(inflammable_component)

