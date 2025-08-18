extends Node

var current_sabotage

# Maybe add signals for this code so that others know whats up

# List of all the different sabotage types
enum SabotageType {
	RATS,
	WATER,
	POWER,
	FIRE,
	CRITIC,
	CRATE,
}

func _process(_delta : float) -> void:
	run_sabotages()

# Activate the different sabotages
func run_sabotages() -> void:
	#print("current sabotage:", current_sabotage)
	if current_sabotage == SabotageType.RATS:
		print("Running rat swarm sabotage...")
	elif current_sabotage == SabotageType.WATER:
		print("Running water sabotage...")
	elif current_sabotage == SabotageType.POWER:
		print("Running power sabotage...")
	elif current_sabotage == SabotageType.FIRE:
		print("Running fire sabotage...")
	elif current_sabotage == SabotageType.CRITIC:
		print("Running critic sabotage...")
	elif current_sabotage == SabotageType.CRATE:
		print("Running crate sabotage...")
	#else:
		#print("No sabotage active.")