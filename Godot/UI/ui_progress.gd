@tool
class_name CustomProgressBar
extends Control

signal finshed
@export var current_progress : float = 0.0 : set = set_amount

func set_amount(_amount : float):
	$TextureProgressBar.value = clamp(_amount,0,1)
	current_progress = $TextureProgressBar.value
	_update_colour()


func add_amount(_amount : float):
	$TextureProgressBar.value += clamp(_amount,0,1)
	current_progress = $TextureProgressBar.value
	_update_colour()


func remove_amount(_amount : float):
	$TextureProgressBar.value -= clamp(_amount,0,1)
	current_progress = $TextureProgressBar.value
	_update_colour()

func _update_colour():
	$TextureProgressBar.tint_progress = hsv_lerp("#fcff9c", "49de67", $TextureProgressBar.value - 0.3)
	pass

func _on_timer_timeout() -> void:
	add_amount(0.01)

#AI geenerated :(
func hsv_lerp(color_a: Color, color_b: Color, t: float) -> Color:
	# Convert both colors to HSV
	var h1 = color_a.h
	var s1 = color_a.s
	var v1 = color_a.v

	var h2 = color_b.h
	var s2 = color_b.s
	var v2 = color_b.v

	# Interpolate hue correctly (circular interpolation)
	var dh = fmod(h2 - h1 + 1.0, 1.0)
	if dh > 0.5:
		dh -= 1.0
	var h = fmod(h1 + dh * t + 1.0, 1.0)

	# Lerp saturation and value linearly
	var s = lerp(s1, s2, t)
	var v = lerp(v1, v2, t)

	# Also lerp alpha
	var a = lerp(color_a.a, color_b.a, t)

	# Convert back to RGB
	return Color.from_hsv(h, s, v, a)

func _check_progress():
	if  $TextureProgressBar.value >= 1:
		emit_signal("finshed")
