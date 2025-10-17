class_name PopupManager
extends Node

var active_popup: NetworkPopup = null
var popup_scene: PackedScene = preload("res://scenes/Network_Layer/network_popup.tscn")
var popup_layer: CanvasLayer = null


## Setup the popup layer
func _ready():
	_setup_popup_layer()


## Setup a dedicated CanvasLayer for popups.
## Prevent them from being hidden by other UI.
func _setup_popup_layer():
	popup_layer = CanvasLayer.new()
	popup_layer.name = "PopupLayer"
	popup_layer.layer = 100
	add_child(popup_layer)


## Show a temporary notification popup
## @param message: The message to display
## @param duration: How long to display before fading out
func show_notification(message: String, duration: float = 3.0):
	# Hide any existing popup before showing a new one
	if active_popup:
		active_popup.hide_popup()
	var popup = popup_scene.instantiate()
	popup_layer.add_child(popup)
	popup.setup(message, duration)
	active_popup = popup
	popup.tree_exited.connect(_on_popup_removed)
	# Center the popup in the viewport
	await get_tree().process_frame
	var viewport_size = get_viewport().get_visible_rect().size
	popup.position.x = (viewport_size.x - popup.size.x) / 2
	popup.position.y = (viewport_size.y - popup.size.y) / 2


## Called when a popup is removed from the tree
func _on_popup_removed():
	active_popup = null


## Hide the active popup
func hide_popup():
	if active_popup:
		active_popup.hide_popup()
		active_popup = null


## Hide the active popup with animation
func hide_popup_animated():
	if active_popup:
		active_popup.hide_popup_animated()
		active_popup = null


## Check if a popup is currently active
## @return: True if a popup is currently shown
func has_active_popup() -> bool:
	return active_popup != null
