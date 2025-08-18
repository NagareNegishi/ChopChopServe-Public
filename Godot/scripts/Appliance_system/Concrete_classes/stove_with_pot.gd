class_name StoveWithPot
extends Stove


## Attach cookware to the stove
func _ready():
	super._ready()
	add_cookware("pot")

	test()#----------------------------------------------------------------------

#----------------------------------------------------------------------
func test():
	var pot = contents[0]
	if pot:
		pot.test()
	start_cook()
#----------------------------------------------------------------------