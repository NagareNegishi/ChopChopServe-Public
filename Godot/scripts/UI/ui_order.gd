class_name UIOrder
extends Control

@onready var item_image : TextureRect = $MenuItem2
@onready var image_image2 : TextureRect = $MenuItem2/MenuItem
@onready var progress_bar : ProgressBar = $ProgressBar

## Sets the order to the given menu item
## @param item the MenuItem the customer is ordering
## @return bool returns true if successful
func set_order(item : MenuItem) -> bool:
	if item == null:
		push_error("ERROR: ENTER VALID MENU ITEM")
		return false
	
	if item.ui_texture == null:
		print(item.get_meal_name())
		push_error("ERROR: UI_TEXTUIRE IS NULL")
		return false
	
	item_image.texture = item.ui_texture
	image_image2.texture = item.ui_texture
	restart()
	return true


## Adds to the given progress amount
## @param amount how much you are adding to the current progress
## @return void
func add_amount(amount : float) -> void:
	progress_bar.value += amount


## Sets progress to a selected amount
## @param amount sets the amount directly
## @return void
func set_amount(amount : float) -> void:
	amount = clampf(amount, 0, 1)
	progress_bar.value = amount


## Removes amount from the current progress
## @param amount amount removed from current progress
## @return void
func remove_amount(amount : int) -> void:
	amount = clamp(amount, 0, 1)
	progress_bar.value -= amount


## Restarts the timers progress
## @return void
func restart() -> void:
	progress_bar.value
