extends Control

var food_item
var is_open: bool = false
var applianceInstance
var cw 

@export var type : ProgressType
@onready var progress_bar : ProgressBar = $ProgressBar

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


func _on_add_cookware(cookware, appliance): # Need to do something else for the sink
	if cookware == null:
		print("Warning: cookware is null!")
	if appliance == null:
		print("Warning: appliance is null!")
	
	cookware.connect("food_placed", Callable(self, "_on_food_added"))
	cookware.connect("food_taken", Callable(self, "_on_food_taken"))
	
	if cookware is not ChoppingBoard:
		cookware.connect("new_average", Callable(self, "_on_average_updated"))
	
	if get_max_value(get_cooking_style()):
		progress_bar.max_value = get_max_value(get_cooking_style())
	else:
		progress_bar.max_value = 3
	
	
	if cookware.contents.size() >= 1:
		food_item = cookware.contents[0]
		if not food_item.is_connected("cooking", Callable(self, "_on_food_cooking")):
			food_item.connect("cooking", Callable(self, "_on_food_cooking"))
			is_open = true
	
	if appliance != null:
		appliance.connect("cookware_taken", Callable(self, "_on_cookware_taken"))
	
	cw = cookware
	applianceInstance = appliance


func _on_food_added(cookware, contents):
	is_open = true
	
	if food_item and food_item.is_connected("cooking", Callable(self, "_on_food_cooking")):
		food_item.disconnect("cooking", Callable(self, "_on_food_cooking"))
	
	if contents.size()>= 1:
		food_item = contents.get(0)
	elif contents is Food:
		food_item = contents
	
	#print("food added, cook time is: ", food_item.get_cook_time(get_cooking_style()))
	if get_max_value(get_cooking_style()):
		progress_bar.max_value = get_max_value(get_cooking_style())
	else:
		progress_bar.max_value = 3
	
	if food_item.get_cook_time(get_cooking_style()) == 0:
		progress_bar.value = progress_bar.max_value
	
	if not food_item.is_connected("cooking", Callable(self, "_on_food_cooking")):
		food_item.connect("cooking", Callable(self, "_on_food_cooking"))

var _contents
func _on_food_taken(cookware, contents):
	_contents = contents
	if contents is Array and contents.size() >= 1:
		
		for item in contents:
			if !item.is_cooked:
				item.set_cook_time(get_max_value(get_cooking_style()), get_cooking_style())
				#print("progress value = ", progress_bar.value,"item cook time = ",item.get_cook_time)
	elif contents is Food:
		if !contents.is_cooked:
			contents.set_cook_time(get_max_value(get_cooking_style()), get_cooking_style())
			#print("progress value = ", progress_bar.value,"item cook time = ",contents.get_cook_time)
	
	if food_item and food_item.is_connected("cooking", Callable(self, "_on_food_cooking")):
		food_item.disconnect("cooking", Callable(self, "_on_food_cooking"))
	
	progress_bar.value = 0
	is_open = false
	food_item = null

func _on_cookware_taken(cookware, appliance):
	#print("cookware is taken")
	if cookware and cookware.is_in_group("Appliance"):
		if cookware.is_connected("food_placed", Callable(self, "_on_food_added")):
			cookware.disconnect("food_placed", Callable(self, "_on_food_added"))
		if cookware.is_connected("food_taken", Callable(self, "_on_food_taken")):
			cookware.disconnect("food_taken", Callable(self, "_on_food_taken"))
		if cookware.is_connected("new_average", Callable(self, "_on_average_updated")):
			cookware.disconnect("new_average", Callable(self, "_on_average_updated"))
		
		if cookware.contents.size()>=1:
			for item in cookware.contents:
				if item.is_connected("cooking", Callable(self, "_on_food_cooking")):
					item.disconnect("cooking", Callable(self, "_on_food_cooking"))
		elif cookware.contents is Food:
			if cookware.contents.is_connected("cooking", Callable(self, "_on_food_cooking")):
					cookware.contents.disconnect("cooking", Callable(self, "_on_food_cooking"))
	
	
	is_open = false
	progress_bar.value = 0
	food_item = null
	for item in cookware.contents:
		item.set_cook_time(get_max_value(get_cooking_style()), get_cooking_style())

func _on_food_cooking():
	progress_bar.value += 1
	if progress_bar.value == 15 and get_cooking_style() == ApplianceFactory.CookingStyle.BOIL and \
	_contents != null and GlobalScript.array_check_tomato(_contents): pass

# Returns the cooking style of the cookware + blender
func get_cooking_style():
	if cw == null: return ApplianceFactory.CookingStyle.BLEND
	
	return cw.cooking_style


func change_visibility(turn_on: bool):
	var owner_team
	
	if applianceInstance:
		owner_team = applianceInstance.get_appliance_owner()
	elif applianceInstance == null and (cw is Blender || cw is Sink || cw is ChoppingBoard):
		owner_team = cw.get_appliance_owner()
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


func _set_texture(texture_type : ProgressType):
	$TextureRect.texture = TEXTURE[type]
