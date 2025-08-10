class_name StoveWithPot
extends Stove


## Attach cookware to the stove
func _ready():
    super._ready()
    add_cookware("pot")