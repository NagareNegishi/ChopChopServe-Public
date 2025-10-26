extends Label

var start_time_hour = 9
var start_time_min = 30

func _ready():
	return
	GameState.connect("time_tick", Callable(self, "_on_time_tick"))

func _on_time_tick(current_time):
	var time = current_time + start_time_min
	var hour = start_time_hour
	
	if time >= 60:
		time = time % 60
		hour += 1
	
