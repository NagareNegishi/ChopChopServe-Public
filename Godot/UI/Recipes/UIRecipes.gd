class_name UIRecipes extends Control

var all_menu_items = {}
var curr_menu_items = []
var index : int = 0

@onready var recipe : UIRecipe = $UiRecipe
@onready var arrows := [$TextureRect, $TextureRect2, $KeyboardL, $KeyboardJ]
func _ready() -> void:
	visibility_changed.connect(_on_visible_change)
	_load_items()
	
func _on_visible_change():
	set_physics_process(visible)
	_set_curr_menu_items()
	
func _physics_process(delta: float) -> void:
	if curr_menu_items.size() <= 1: return
	if Input.is_action_just_pressed("LB"): backward()
	if Input.is_action_just_pressed("RB"): forward()
	


func forward():
	index = index + 1 if index + 1 <= curr_menu_items.size() - 1 else 0
	recipe.set_info(all_menu_items[curr_menu_items[index]])

func backward():
	index = index - 1 if index - 1 >= 0 else curr_menu_items.size() - 1
	recipe.set_info(all_menu_items[curr_menu_items[index]])

func _set_curr_menu_items():
	curr_menu_items = GameState._get_available_food_names()
	index = 0
	var item = all_menu_items[curr_menu_items[index]]
	
	for part in arrows:
		part.visible = curr_menu_items.size() > 1
	if !item: return
	recipe.set_info(item)


func _load_items():
	var dir := DirAccess.open("res://scripts/Food/MenuItems/")
	if not dir: return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".gd"):
			var script_path = "res://scripts/Food/MenuItems/" + file_name
			var script = load(script_path)
			if script:
				var key = file_name.get_basename()
				all_menu_items[key] = script.new()
		file_name = dir.get_next()
	dir.list_dir_end()
