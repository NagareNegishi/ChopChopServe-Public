class_name UIRecipe extends Control

signal done()
@onready var _progress : ProgressBar = $ProgressBar
@onready var recipe_name : Label = $Dish
@onready var recipe_final : TextureRect = $MenuItem
@onready var row1 : HBoxContainer = $Ingredients/Row1
@onready var row2 : HBoxContainer = $Ingredients/Row2
@onready var progress_parts = [$Panel3, $Panel4, $ProgressBar, $Ticks, $Label, $UiInput] 
@onready var cook_box = $CookBox
@export var hide : bool = false
var col : Color = Color("939393")
var map_recipe = {
	"tomato_soup" : "soup_tomato"
}
var is_skip = false
var multi = 1
var peeps = 0
func _ready() -> void:
	_progress.value = 0
	reset()
	set_physics_process(false)
	#set_info(bolognese.new())

	
	for part in progress_parts:
		part.visible = false

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Interact") && visible: 
		is_skip = !is_skip
		_skip.rpc(ENetManager.get_my_id(), is_skip)
	_progress.value += delta * 0.6 * multi
	if !ENetManager.is_host(): return
	if _progress.value >= _progress.max_value: hide_self.rpc()


@rpc("any_peer", "call_local")
func _skip(id : int, skip : bool):
	var inx = ENetManager.get_player_list().find(id)
	$Ticks.get_child(inx).modulate = col if !skip else GlobalScript.player_outline_colours[inx]
	peeps = peeps + 1 if skip else peeps - 1
	multi = 3.5 if peeps >= ENetManager.get_player_list().size() else 1
		


func set_info(recipe_script : String):
	if map_recipe.has(recipe_script): recipe_script = map_recipe[recipe_script]
	var script = "res://scripts/Food/MenuItems/" + recipe_script +".gd"
	var recipe = load(script).new()
	assert(recipe)
	recipe_name.text = recipe.ui_meal_name
	recipe_final.texture = recipe.ui_texture
	_add_ingredients(recipe)
	_add_cookware(recipe)
	

@rpc("any_peer", "call_local")
func hide_self():
	set_physics_process(false)
	visible = false
	emit_signal("done")

func reset():
	set_physics_process(false)
	_progress.value = 0
	var index = 0
	multi = 1
	peeps = 0
	is_skip = false
	for c :  TextureRect in $Ticks.get_children():
		c.modulate = col
		index += 1
		c.visible = index <= ENetManager.get_player_list().size()

func _add_ingredients(recipe : MenuItem):
	_clear_ingredients()
	var states : Dictionary = recipe.ui_states
	var ingredient_scene = preload("res://UI/Recipes/ui_recipe_ingredient.tscn")
	var scene : UIRecipeIngred
	var index : int = 0
	
	for food in states.keys():
		scene = UIRecipeIngred.create(states[food][0], recipe.ingredients[index])
		if index < 2:
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


func _add_cookware(recipe : MenuItem):
	_clear_cookware()
	var states : Dictionary = recipe.ui_states
	var org : Dictionary
	var scene : UICook
	
	for food in states.keys():
		var type = states[food][states[food].size() - 1] 
		if type == "NONE": continue
		if org.has(type): 
			var list = org.get(type)
			list.append(food)
			org[type] = list
			continue
		org.set(type, [food])

	for key in org:
		scene = preload("res://UI/Recipes/UI_Cook.tscn").instantiate()
		scene.set_info(key, org[key])
		cook_box.add_child(scene)
func _clear_cookware():
	for child in cook_box.get_children():
		child.queue_free()

func _progress_hide(is_hide : bool):
	if !is_hide: reset()
	for part in progress_parts:
		part.visible = !is_hide
	
