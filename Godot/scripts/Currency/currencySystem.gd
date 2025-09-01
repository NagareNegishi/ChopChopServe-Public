extends Node

# Starting CUrrency
# Change later - high for testing use
var total_cur_team = {
	1: 10000.0,
	2: 10000.0
}

# Current starting currency is 200
# Change this back later !!
#@export var total_currency: float = 10000.0
signal currency_changed(new_currency: float)


# Add more currency to the total
func add_currency(teamID: int, more_currency : float) -> void:
    if check_currency(teamID, more_currency):
        total_cur_team[teamID]+=more_currency
        currency_changed.emit(teamID, total_cur_team[teamID])
    else:
        total_cur_team[teamID] = total_cur_team[teamID]
        print("Not enough currency to add: %d" % more_currency)

# Minus currency from the total
func minus_currency(teamID, less_currency) -> void:
    # Make it a negitive number
    add_currency(teamID, -less_currency)

# Get the current total_currency
func get_currency(teamID: int) -> float:
    return total_cur_team[teamID]

# Check that the new currency will still be above 0
func check_currency(teamID: int, currency: float) -> bool:
    return total_cur_team[teamID] + currency >= 0