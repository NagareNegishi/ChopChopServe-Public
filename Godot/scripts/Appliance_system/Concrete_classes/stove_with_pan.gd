class_name StoveWithPan
extends Stove


## Attach cookware to the stove
func _ready():
	super._ready()
	cooking_style = ApplianceFactory.CookingStyle.PAN_FRY
	_add_cookware("frying_pan")
