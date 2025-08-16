extends Node

@export var total_reputation: float = 20.0

signal reputation_changed(new_reputation: float)

# Function to add to the total reputation
func add_reputation(amount: float) -> void:
	# Clamp the total_reputation between 0 and 100
	total_reputation = clamp(total_reputation + amount, 0, 100)
	print("Reputation changed to: %d" % total_reputation)
	reputation_changed.emit(total_reputation)

# Function to call to minus from the total_reputation
func minus_reputation(amount: float) -> void:
	# Send it to add but with a -
	add_reputation(-amount)

# Function to get the current reputation values
func get_reputation() -> float:
	return total_reputation
