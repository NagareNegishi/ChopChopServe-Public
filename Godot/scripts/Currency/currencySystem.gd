extends Node

# Current starting currency is 200
@export var total_currency: float = 200.0

# Add more currency to the total
func add_currency(more_currency : float) -> void:
    total_currency+=more_currency

# Minus currency from the total
func minus_currency(less_currency) -> void:
    # Check if the new total is still > 0
    if check_currency(less_currency):
        total_currency -= less_currency
    else:
        # TODO: Trigger UI feedback here
        print("not enough currency !!")

# Get the current total_currency
func get_currency() -> float:
    return total_currency

# Check that the new currency will still be above 0
func check_currency(currency: float) -> bool:
    return total_currency - currency >= 0