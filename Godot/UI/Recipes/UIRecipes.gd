class_name UIRecipes extends Control

var curr_menu_items = []
var index : int = 0

@onready var recipe : UIRecipe = $UiRecipe
@onready var arrows := [$TextureRect, $TextureRect2, $J, $L, $LB, $R2]
func _ready() -> void:
	visibility_changed.connect(_on_visible_change)
	
func _on_visible_change():
	set_physics_process(visible)
	_set_curr_menu_items()
	
func _physics_process(delta: float) -> void:
	if curr_menu_items.size() <= 1: return
	if Input.is_action_just_pressed("LB"): backward()
	if Input.is_action_just_pressed("RB"): forward()
	


func forward():
	index = index + 1 if index + 1 <= curr_menu_items.size() - 1 else 0
	recipe.set_info(curr_menu_items[index])

func backward():
	index = index - 1 if index - 1 >= 0 else curr_menu_items.size() - 1
	recipe.set_info(curr_menu_items[index])

func _set_curr_menu_items():
	curr_menu_items = GameState._get_available_food_names()
	var item : String = curr_menu_items[index]
	
	for part in arrows:
		part.visible = curr_menu_items.size() > 1
	if !item: return
	recipe.set_info(item)
