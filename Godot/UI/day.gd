extends Label

func _ready():
	GameState.connect("end_phase", Callable(self, "_on_day_increase"))

func _on_day_increase():
	text = "Day "+str(GameState.current_day)
