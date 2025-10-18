extends Control

@onready var sink = $"../.."
@onready var progbar = $ProgressBar
@onready var sprite = $"../../Sprite3D"
var timer := Timer.new()
var dish

func _ready():
	progbar.max_value = 3
	progbar.step = 1
	progbar.value = 1
	
	sink.connect("start", Callable(self, "_on_dish_added"))
	sink.connect("stop", Callable(self, "_on_dish_taken"))
	change_visibility(false)

func _on_dish_added(item):
	print("Washing started")
	if item is Plate:
		change_visibility(true)
		progbar.value = item.get_clean_level()
		dish = item

func _on_dish_taken():
	print("Washing stopped")
	progbar.value = 0
	change_visibility(false)


func _on_sink_progress():
	progbar.value += 1
	dish.set_clean_level(dish.get_clean_level()+1)

func change_visibility(turn_on: bool):
	var owner_team
	
	if sink:
		owner_team = sink.get_appliance_owner()
	else:
		owner_team = 0
	var my_id = ENetManager.get_my_id()
	var my_team = ENetManager.get_team(my_id)
	
	visible = (my_team == owner_team and turn_on)
