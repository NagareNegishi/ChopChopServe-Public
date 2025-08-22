extends Node

# Current starting currency is 200
# Change this back later !!
@export var total_currency: float = 1000.0
signal currency_changed(new_currency: float)

# Add more currency to the total
func add_currency(more_currency : float) -> void:
    if check_currency(more_currency):
        print("Adding currency: %d" % more_currency)
        total_currency+=more_currency
        currency_changed.emit(total_currency)
    else:
        total_currency = total_currency
        print("Not enough currency to add: %d" % more_currency)

# Minus currency from the total
func minus_currency(less_currency) -> void:
    # Make it a negitive number
    add_currency(-less_currency)

# Get the current total_currency
func get_currency() -> float:
    return total_currency

# Check that the new currency will still be above 0
func check_currency(currency: float) -> bool:
    return total_currency + currency >= 0