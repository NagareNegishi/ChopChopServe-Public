extends Node

# Currently starting rep is 20
@export var total_reputation: float = 20.0

signal reputation_changed(new_reputation: int)

# Gain new Reputation
func add_reputation(gain_rep: float) -> void:
    print("Checking reputation amount: %d" % gain_rep)
    if check_max_amount(gain_rep):
        print("Adding reputation: %d" % gain_rep)
        total_reputation+=gain_rep
    else:
        total_reputation = 100
        print("Reputation is full, set to 100")
    reputation_changed.emit(total_reputation)

# Lose some Reputation
func minus_reputation(less_rep : float) -> void:
    print("Adding reputation: %d" % less_rep)
    if check_min_amount(less_rep):
        total_reputation-=less_rep
    else:
        # TODO: Add UI Feedback here
        print("Lost all of your Reputation")
        total_reputation = 0
    reputation_changed.emit(total_reputation)

# Get the current total_reputation
func get_reputation() -> float:
    return total_reputation

# Check that you haven't lost all of your reputation
func check_min_amount(new_rep: float) -> bool:
    print("Checking < 0")
    # If the Rep is less than 0 it is 0
    # So we DON'T want to minus from it
    if total_reputation - new_rep <= 0:
        print("lost all your reputation!")
        return false
    return true;

# Check that Your not going abouve 100
func check_max_amount(new_rep: float) -> bool:
    print("checking > 100")
    if total_reputation + new_rep > 100:
        print("Reputation is full, set to 100")
        return false
    return true