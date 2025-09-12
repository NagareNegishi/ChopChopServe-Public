class_name Freezer
extends MultiFoodCrate

## Setup the model instance
func _init():
	super._init()
	model_scene = preload("res://assets/models/furniture/Fridge.glb")
	supply_names = ["Tomato", "Water"]
