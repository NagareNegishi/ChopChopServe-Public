extends Label

var start_time_hour = 9
var start_time_min = 30
@onready var type = $TimeType
func _ready():
	GameState.connect("time_tick", Callable(self, "_on_time_tick"))

func _on_time_tick(current_time):
	var time = current_time + start_time_min
	var hour = start_time_hour
	
	if time >= 60:
		time = time % 60
		hour += 1
	
	display(hour, time)

func display(hour, min):
	if hour < 12:
		type.text = "am"
	else:
		type.text = "pm"
	
	if min < 10:
		text = ""+str(hour)+":0"+str(min)
	else:
		text = ""+str(hour)+":"+str(min)
	
