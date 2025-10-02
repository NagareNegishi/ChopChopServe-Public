extends Control

var cw # Cookware
var food_item
var is_open: bool = false
var contents: Array
var applianceInstance

@export var type : ProgressType
@onready var texture_rect : TextureRect = $TextureRect
@onready var progress_bar = $ProgressBar

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

func _ready() -> void:
	_set_texture(type)

# Connecting food timer signal to the progress bar
func _on_cookware_signal(food):
	if food_item and food_item.is_connected("cooking", Callable(self, "_on_food_signal")):
		food_item.disconnect("cooking", Callable(self, "_on_food_signal"))
	
	contents = food
	if contents.size() > 0:
		food_item = contents[0]
	
	print(food_item)
	progress_bar.max_value = get_max_value(get_cooking_style())
	#progress_bar.value = food_item.get_current_progress()
	
	
	if not food_item.is_connected("cooking", Callable(self, "_on_food_signal")):
		food_item.connect("cooking", Callable(self, "_on_food_signal"))
	
	is_open = true

# On food signal we want to change the progress bas value
func _on_food_signal():
	progress_bar.value += 1


# Connect the cookware signal so when things are added to the cookware it goes to _on_cookware_signal 
# function to then connect the food timer up to change the progress bar value
func connect_cookware(cookware):
	if cookware and cookware.is_in_group("Appliance"):
		cookware.connect("food_placed", Callable(self, "_on_cookware_signal"))
		if cookware.contents.size() > 0:
			is_open = true
		
		if not cookware.is_connected("new_average", Callable(self, "_on_average_updated")) and cookware != ChoppingBoard:
			cookware.connect("new_average", Callable(self, "_on_average_updated"))
	else:
		push_error("In appliance progress bar -- connect_cookware() -- either there 
		is nothing passed of it is not an appliance")


# Connect the take_all signal so that when things are taken from cookware it makes the progress bar
# disappear
func connect_take_all(cookware):
	print("IN CONNECT")
	print(cookware)
	
	if cookware and cookware.is_in_group("Appliance"):
		cookware.connect("food_taken",Callable(self, "_on_food_taken"))


# Function to chnage boolean value when items are taken from the cookware or blender
func _on_food_taken():
	print("FOOD OR COOKWARE TAKEN")
	
	if food_item and food_item.is_in_group("Food") and food_item.is_connected("cooking", Callable(self, "_on_food_signal")):
		print("IS FOOD")
		food_item.disconnect("cooking", Callable(self, "_on_food_signal"))
	
	reset()


func _on_cookware_taken(item):
	if item and item.is_in_group("Appliance"):
		print("IS APPLIANCE")
		if cw.is_connected("food_placed", Callable(self, "_on_cookware_signal")):
			cw.disconnect("food_placed", Callable(self, "_on_cookware_signal"))
		if cw.is_connected("food_taken", Callable(self, "_on_food_or_cookware_taken")):
			cw.disconnect("food_taken", Callable(self, "_on_food_or_cookware_taken"))
		if cw.is_connected("new_average", Callable(self, "_on_average_updated")):
			cw.disconnect("new_average", Callable(self, "_on_average_updated"))
	
	
	reset()
	cw = null


# Returns the cooking style of the cookware + blender
func get_cooking_style():
	if cw ==null: return ApplianceFactory.CookingStyle.CHOP
	
	return cw.cooking_style


func change_visibility(turn_on: bool):
	var owner_team
	if applianceInstance:
		owner_team = applianceInstance.get_appliance_owner()
	else:
		owner_team = 0
	var my_id = ENetManager.get_my_id()
	var my_team = ENetManager.get_team(my_id)
	
	visible = (my_team == owner_team and turn_on)


# When another ingredient is added to the cookware get new value of the progress bar
func _on_average_updated(new_average: float):
	progress_bar.value = progress_bar.max_value - new_average


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
func _on_add_appliance(cookware, appliance): # cookware: frying_pan, overn_tray, pot, chooping_board
	connect_cookware(cookware)
	connect_take_all(cookware)
	if appliance != null:
		appliance.connect("cookware_taken", Callable(self, "_on_cookware_taken"))
		applianceInstance = appliance
	cw = cookware
	if cookware.contents.size() > 0:
		_on_cookware_signal(cookware.contents)


# Is different because this is PoweredAppliance and not Cookware
func _on_blender_signal(cookware, blender):
	cookware = blender
	cookware.connect("average_updated", Callable(self, "_on_average_updated"))
	applianceInstance = blender
	_on_cookware_signal(cookware)
	connect_take_all(blender)


func _on_chop_table_food_placed(cookware):
	connect_cookware(cookware)
	connect_take_all(cookware)


func reset():
	progress_bar.value = 0
	food_item = null
	is_open = false


func _set_texture(texture_type : ProgressType):
	texture_rect.texture = TEXTURE[texture_type]
