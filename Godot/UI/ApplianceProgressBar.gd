extends TextureProgressBar

var cookware
var food_item
var is_open: bool
var contents: Array

func _process(_delta):
	change_visibility(is_open)

# Connecting food timer signal to the progress bar
func _on_cookware_signal(c):
	max_value = get_max_value(get_cooking_style())
	contents = c
	
	if food_item and food_item.is_connected("cooking", Callable(self, "_on_food_signal")):
		food_item.disconnect("cooking", Callable(self, "_on_food_signal"))
	
	if contents.size() > 0:
		food_item = contents[0]
		
		if not food_item.is_connected("cooking", Callable(self, "_on_food_signal")):
			food_item.connect("cooking", Callable(self, "_on_food_signal"))
	is_open = true

# On food signal we want to change the progress bas value
func _on_food_signal():
	value += 1
	# Dont want the blender to turn orange because food cant burn in there
	if value == max_value and cookware is not Blender: 
		tint_progress = Color8(255,165,0)


# Connect the cookware signal so when things are added to the cookware it goes to _on_cookware_signal 
# function to then connect the food timer up to change the progress bar value
func connect_cookware(c):
	if c and c.is_in_group("Appliance"):
		c.connect("food_placed",Callable(self, "_on_cookware_signal"))
		cookware = c
		
		if not cookware.is_connected("average_updated", Callable(self, "_on_average_updated")):
			cookware.connect("new_average", Callable(self, "_on_average_updated"))


# Connect the take_all signal so that when things are taken from cookware it makes the progress bar
# disappear
func connect_take_all(c):
	if c and c.is_in_group("Appliance"):
		c.connect("food_taken",Callable(self, "_on_food_taken"))


# Function to chnage boolean value when items are taken from the cookware or blender
func _on_food_taken():
	is_open = false


# Returns the cooking style of the cookware + blender
func get_cooking_style():
	return cookware.cooking_style


func change_visibility(turn_on: bool):
	visible = turn_on


# When another ingredient is added to the cookware get new value of the progress bar
func _on_average_updated(new_average: float) -> void:
	value = max_value - new_average


func get_max_value(cook_style: ApplianceFactory.CookingStyle):
	match(cook_style):
			ApplianceFactory.CookingStyle.BOIL:
				return 15
			ApplianceFactory.CookingStyle.BAKE:
				return 10
			ApplianceFactory.CookingStyle.BLEND:
				return 6
			ApplianceFactory.CookingStyle.PAN_FRY, ApplianceFactory.CookingStyle.DEEP_FRY:
				return 10
			_:
				push_error("No cooking style matched in appliance progress bar in get_max_value()")

# Connecting cookware + blender signals to the progress bar
func _on_fryer_add_appliance(c):
	connect_cookware(c)
	connect_take_all(c)

func _on_stove_add_appliance(c):
	connect_cookware(c)
	connect_take_all(c)

func _on_stove_with_pan_add_appliance(c):
	connect_cookware(c)
	connect_take_all(c)

func _on_stove_with_pot_add_appliance(c):
	connect_cookware(c)
	connect_take_all(c)

# Is different because this is PoweredAppliance and not Cookware
func _on_blender_signal(c, blender):
	cookware = blender
	cookware.connect("average_updated", Callable(self, "_on_average_updated"))
	_on_cookware_signal(c)
	connect_take_all(blender)

func _on_oven_add_appliance(c):
	connect_cookware(c)
	connect_take_all(c)
