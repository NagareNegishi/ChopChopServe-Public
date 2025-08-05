extends Node

# what is the starting reputation??
@export var total_reputation: float = 0.0

# Gain new Reputation
func add_reputation(gain_rep: float) -> void:
    total_reputation+=gain_rep

# Lose some Reputation
func minus_reputation(less_rep : float) -> void:
    if check_amount(less_rep):
        total_reputation-=less_rep
    else:
        # TODO: Add UI Feedback here
        print("Lost all of your Reputation")

# Get the current total_reputation
func get_reputation() -> float:
    return total_reputation

# Check that you haven't lost all of your reputation
func check_amount(new_rep: float) -> bool:
    if total_reputation < 100 || total_reputation - new_rep >= 0:
        return true
    return false
    
