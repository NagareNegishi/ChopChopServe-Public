## Kitchen equipment class Container
## Used by PoweredAppliance, like a Pot, Pan, etc.
## Container must be used by PoweredAppliance, it will not work alone
class_name Container
extends Equipment




## Perform cooking logic
## @param power: The power from PoweredAppliance
func cook(power: int) -> bool:
    if current_status == Status.IDLE:
        current_status = Status.USING
        status_changed.emit(current_status)
    elif current_status != Status.USING:
        assert(false, "Do not call cook() unless status is USING")
        return false

    for food in contents:
        if food.has_method("cook"): ## Check the method name!!!!!!!!!!!!!!!!!!!!!!!!
            food.cook(power * coefficient)
        else:
            push_warning("Item " + food.name + " does not implement cook() method")
    return true