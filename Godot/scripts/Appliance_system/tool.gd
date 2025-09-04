## leave it for future expansion, but we may not use it at this stage

## Kitchen equipment class Tool:
## Used with Appliance, like a Knife, Whisk, etc.
## Tool must be used by Player, it will not work alone
class_name Tool
extends Equipment

## Setup the tool
func _ready():
	super._ready()

## Perform cooking logic
## @param power: The power from Player
func cook(power: int) -> bool:
	for food in contents:
		food.startCooking(int(power * coefficient), cooking_style)
	return true
