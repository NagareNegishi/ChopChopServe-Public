class_name SabotageBar extends HBoxContainer


@export var team_id : int 

var sabotage_dict : Dictionary = {}
func _ready() -> void:
	SabotageSystem.sabotage_start.connect(sabotage_start)
	


func sabotage_start(teamID: int, sab_name: String, sab_time: int):
	if teamID == team_id or sab_name == "Rat Swarm" or \
	sab_name == "Fire Spread" or sab_name == "Power Outage": return
	var child = SabotageProgress.create(sab_time, sab_name)
	add_child(child)
