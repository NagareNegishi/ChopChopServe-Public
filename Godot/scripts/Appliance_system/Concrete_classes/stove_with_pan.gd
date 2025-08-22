class_name StoveWithPan
extends Stove


## Attach cookware to the stove
func _ready():
	super._ready()
	_add_cookware("frying_pan")