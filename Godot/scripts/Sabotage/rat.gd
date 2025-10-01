extends MeshInstance3D
class_name rat

# Do the rat personal stuff


var target_path
@onready var rat_mischief := []

func set_target(path: NodePath):
    target_path = path


