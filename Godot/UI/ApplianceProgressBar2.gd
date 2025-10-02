extends ProgressBar

var cookware
var food_item
var is_open: bool = false
var contents: Array
var applianceInstance

@export var type : ProgressType
@onready var texture_rect : TextureRect = $"../TextureRect"

enum ProgressType {
	COOK,
	WASH,
	CHOP,
	MIX
}

var TEXTURE = {
	ProgressType.COOK : ResourceLoader.load("res://assets/textures/misc/fire (2).png"),
	ProgressType.CHOP : ResourceLoader.load("res://assets/textures/misc/meat-cleaver (3).png"),
	ProgressType.MIX : ResourceLoader.load("res://assets/textures/misc/blender (2).png"),
	ProgressType.WASH : ResourceLoader.load("res://assets/textures/misc/sink.png")
}

func _process(_delta):
	change_visibility(is_open)
	#print(is_open)

func _ready() -> void:
	_set_texture(type)
	
	
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
	#if value == max_value and (cookware is not Blender and cookware is not ChoppingBoard) : 
		#tint_progress = Color8(255,165,0)


# Connect the cookware signal so when things are added to the cookware it goes to _on_cookware_signal 
# function to then connect the food timer up to change the progress bar value
func connect_cookware(c):
	if c and c.is_in_group("Appliance"):
		c.connect("food_placed", Callable(self, "_on_cookware_signal"))
		cookware = c
		if cookware.contents.size() > 0:
			is_open = true
		
		if not cookware.is_connected("average_updated", Callable(self, "_on_average_updated")):
			cookware.connect("new_average", Callable(self, "_on_average_updated"))
	else:
		push_error("In appliance progress bar -- connect_cookware() -- either there 
		is nothing passed of it is not an appliance")


# Connect the take_all signal so that when things are taken from cookware it makes the progress bar
# disappear
func connect_take_all(c):
	if c and c.is_in_group("Appliance"):
		c.connect("food_taken",Callable(self, "_on_food_or_cookware_taken"))


# Function to chnage boolean value when items are taken from the cookware or blender
func _on_food_or_cookware_taken(item):
	is_open = false
	
	if item and item.is_in_group("Appliance"):
		if cookware.is_connected("food_placed", Callable(self, "_on_cookware_signal")):
			cookware.disconnect("food_placed", Callable(self, "_on_cookware_signal"))
		if cookware.is_connected("food_taken", Callable(self, "_on_food_or_cookware_taken")):
			cookware.disconnect("food_taken", Callable(self, "_on_food_or_cookware_taken"))
		if cookware.is_connected("new_average", Callable(self, "_on_average_updated")):
			cookware.disconnect("new_average", Callable(self, "_on_average_updated"))
	
	if food_item and food_item.is_connected("cooking", Callable(self, "_on_food_signal")):
		if value == max_value:
			progress_bar_reset()
		food_item.disconnect("cooking", Callable(self, "_on_food_signal"))
		
	
	cookware = null
	food_item = null


# Returns the cooking style of the cookware + blender
func get_cooking_style():
	return cookware.cooking_style


func change_visibility(turn_on: bool):
	if turn_on:
		show()
	else:
		hide()


# When another ingredient is added to the cookware get new value of the progress bar
func _on_average_updated(new_average: float) -> void:
	value = max_value - new_average


func get_max_value(cook_style: ApplianceFactory.CookingStyle):
	match(cook_style):
			ApplianceFactory.CookingStyle.CHOP:
				return 3
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

# When there is an a cookware/equipment added to an appliance it connects to this method
func _on_add_appliance(c, appliance):
	print("Cookware added backKKKKKKKKKKK    ", c)
	connect_cookware(c)
	connect_take_all(c)
	appliance.connect("cookware_taken", Callable(self, "_on_food_or_cookware_taken"))
	
	if c.contents.size() > 0:
		_on_cookware_signal(c.contents)

# Is different because this is PoweredAppliance and not Cookware
func _on_blender_signal(c, blender):
	cookware = blender
	cookware.connect("average_updated", Callable(self, "_on_average_updated"))
	_on_cookware_signal(c)
	connect_take_all(blender)


func _on_chop_table_food_placed(c):
	connect_cookware(c)
	connect_take_all(c)

func progress_bar_reset():
	value = 0


func _set_texture(texture_type : ProgressType):
	texture_rect.texture = TEXTURE[texture_type]


func _on_oven_add_appliance(cookware: Variant) -> void:
	pass # Replace with function body.


func _on_stove_with_pot_add_appliance(cookware: Variant) -> void:
	pass # Replace with function body.
