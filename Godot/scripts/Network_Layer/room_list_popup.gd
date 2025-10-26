class_name RoomListPopup
extends Control

signal room_selected(room_code: String)

@onready var rooms_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/ScrollContainer/RoomsList
@onready var close_button: Button = $Panel/MarginContainer/VBoxContainer/Header/CloseButton
@onready var title_label: Label = $Panel/MarginContainer/VBoxContainer/Header/TitleLabel


## Initialization
func _ready():
	hide()
	close_button.pressed.connect(_on_close_pressed)


## Show the popup and display rooms
func show_rooms(rooms: Array):
	# Clear existing buttons
	for child in rooms_container.get_children():
		child.queue_free()
	
	if rooms.is_empty():
		var no_rooms_label = Label.new()
		no_rooms_label.text = "No active rooms available"
		no_rooms_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rooms_container.add_child(no_rooms_label)
	else:
		# Create button for each room
		for room in rooms:
			var room_button = create_room_button(room)
			rooms_container.add_child(room_button)
	show()


## Create a button for a room
## @param room: Dictionary with room info
## @return: Button node for the room
func create_room_button(room: Dictionary) -> Button:
	Debug.net_log("Creating button for room: " + str(room))
	var button = Button.new()
	var time_str = format_time_remaining(room["expires_in"])
	button.text = "%s - %s remaining" % [room["room_code"], time_str]
	button.custom_minimum_size = Vector2(300, 40)
	button.pressed.connect(_on_room_button_pressed.bind(room["room_code"]))
	return button


## Format time remaining into readable string
## @param seconds: Time remaining in seconds
## @return: Formatted time string
func format_time_remaining(seconds: int) -> String:
	var hours = int(float(seconds) / 3600.0)
	var minutes = int(float(seconds % 3600) / 60.0)
	var secs = seconds % 60
	if hours > 0:
		return "%dh %dm" % [hours, minutes]
	elif minutes > 0:
		return "%dm %ds" % [minutes, secs]
	else:
		return "%ds" % secs


## Handle room button pressed
## @param room_code: Code of the selected room
func _on_room_button_pressed(room_code: String):
	room_selected.emit(room_code)
	hide()


## Handle close button pressed
func _on_close_pressed():
	hide()
