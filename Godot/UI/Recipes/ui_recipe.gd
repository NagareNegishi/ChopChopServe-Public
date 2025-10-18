class_name UIRecipe extends Control

signal done()
@onready var _progress : ProgressBar = $ProgressBar
@onready var recipe_name : Label = $Dish
@onready var recipe_final : TextureRect = $MenuItem
@onready var row1 : HBoxContainer = $Ingredients/Row1
@onready var row2 : HBoxContainer = $Ingredients/Row2
@onready var progress_parts = [$Panel3, $Panel4, $ProgressBar, $Ticks] 

@export var hide : bool

func _ready() -> void:
	_progress.value = 0
	reset()
	set_physics_process(false)
	#set_info(bolognese.new())

	for part in progress_parts:
		part.visible = false
	
func _physics_process(delta: float) -> void:
	_progress.value += delta * 0.25
	if !ENetManager.is_host(): return
	if _progress.value >= _progress.max_value: hide_self()


func set_info(recipe : MenuItem):
	assert(recipe)
	recipe_name.text = recipe.ui_meal_name
	recipe_final.texture = recipe.ui_texture
	_add_ingredients(recipe)
	


func hide_self():
	set_physics_process(false)
	visible = false
	emit_signal("done")

func reset():
	set_physics_process(false)
	_progress.value = 0

func _add_ingredients(recipe : MenuItem):
	_clear_ingredients()
	var states : Dictionary = recipe.ui_states
	var ingredient_scene = preload("res://UI/Recipes/ui_recipe_ingredient.tscn")
	var scene : UIRecipeIngred
	var index : int = 0
	
	for food in states.keys():
		scene = UIRecipeIngred.create(states[food][0], recipe.ingredients[index])
		if row1.get_children().size() < 2:
			row1.add_child(scene)
			index += 1
			continue
		row2.add_child(scene)
		index += 1

func _clear_ingredients():
	for child in row1.get_children():
		child.queue_free()
	for child in row2.get_children():
		child.queue_free()

func start():
	set_physics_process(true)
