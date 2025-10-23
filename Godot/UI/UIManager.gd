extends Node

signal recipe_ui_visible(is_visible : bool)

var load_screen : LoadingScreen
var recipe_screen : UIRecipe
var pause_menu : Pause
var recipe_tab : UIRecipes

@onready var canvas_layer : CanvasLayer = CanvasLayer.new()

func _ready() -> void:
	add_child(canvas_layer)
	canvas_layer.visible = false
	canvas_layer.layer = 1000
	
	load_screen = setup_ui(preload("res://UI/UI_LoadingScreen.tscn"))
	recipe_screen = setup_ui(preload("res://UI/Recipes/UI_Recipe.tscn"))
	recipe_screen._progress_hide(false)
	pause_menu = setup_ui(preload("res://UI/UI_Pause.tscn"))
	recipe_tab = setup_ui(preload("res://UI/Recipes/UI_RecipesInGame.tscn"))
	
	recipe_screen.done.connect(_done)
	

func setup_ui(scene : PackedScene):
	var ui = scene.instantiate()
	ui.visible = false
	canvas_layer.add_child(ui)
	return ui
	
#================== LOADING SCREEN ======================


func play_load():
	_server_play_load.rpc()


@rpc("any_peer", "call_local")
func _server_play_load():
	if !ENetManager.is_host(): return
	_client_play_load.rpc()


@rpc("any_peer", "call_local")
func _client_play_load():
	load_screen.visible = true
	canvas_layer.visible = true
	load_screen.play()


#================== RECIPE SCREEN ======================


func show_recipe(recipe: MenuItem):
	_server_show_recipe.rpc(recipe)


@rpc("any_peer", "call_local")
func _server_show_recipe(recipe: MenuItem):
	if !ENetManager.is_host(): return
	recipe_ui_visible.emit(true)
	_client_show_recipe.rpc_id(1, recipe)


@rpc("authority", "call_local")
func _client_show_recipe(recipe: MenuItem):
	recipe_screen.visible = true
	canvas_layer.visible = true
	get_tree().paused = true
	recipe_screen.set_info(recipe)
	recipe_screen.reset()
	recipe_screen.start()
	

func _done():
	recipe_screen.visible = false
	canvas_layer.visible = false
	recipe_screen.reset()
	get_tree().paused = false
	recipe_ui_visible.emit(false)


#================== RECIPE TAB SCREEN ======================

func show_recipes_tab(show : bool):
	GlobalScript.get_local_player().disable_controls(show, show)
	canvas_layer.visible = show
	recipe_tab.visible = show

#================== PAUSE ======================

func pause(pause : bool):
	if pause:
		show_recipes_tab(false)
		
	pause_menu.toggle_visible(true)
	
