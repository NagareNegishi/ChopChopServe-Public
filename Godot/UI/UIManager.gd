extends Node

signal recipe_ui_visible(is_visible : bool)

var load_screen : LoadingScreen
var recipe_screen : UIRecipe
var pause_menu : Pause
var recipe_tab : UIRecipes

@onready var canvas_layer : CanvasLayer = CanvasLayer.new()

func _ready() -> void:
	var load_scene : PackedScene = preload("res://UI/UI_LoadingScreen.tscn")
	load_screen = load_scene.instantiate()
	
	var recipe_scene : PackedScene = preload("res://UI/Recipes/UI_Recipe.tscn")
	recipe_screen = recipe_scene.instantiate()
	
	var pause_scene : PackedScene = preload("res://UI/UI_Pause.tscn")
	pause_menu = pause_scene.instantiate()
	
	var recipes_screen : PackedScene = preload("res://UI/Recipes/UI_RecipesInGame.tscn")
	recipe_tab = recipes_screen.instantiate()
	
	canvas_layer.visible = false
	canvas_layer.layer = 1000
	
	load_screen.visible = false
	recipe_screen.visible = false
	pause_menu.visible = false
	
	add_child(canvas_layer)
	canvas_layer.add_child(load_screen)
	canvas_layer.add_child(recipe_screen)
	canvas_layer.add_child(pause_menu)
	canvas_layer.add_child(recipe_tab)
	recipe_screen.done.connect(_done)
	


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
	if ENetManager.is_host(): return
	recipe_ui_visible.emit(true)
	_client_show_recipe.rpc_id(1, recipe)


@rpc("authority", "call_local")
func _client_show_recipe(recipe: MenuItem):
	recipe_screen.visible = true
	canvas_layer.visible = true
	recipe_screen.set_info(recipe)
	recipe_screen.reset()
	recipe_screen.start()
	

func _done():
	recipe_screen.visible = false
	canvas_layer.visible = false
	recipe_screen.reset()
	recipe_ui_visible.emit(false)


#================== RECIPE TAB SCREEN ======================

func show_recipes_tab(show : bool):
	GlobalScript.get_local_player().disable_controls(show, show)
	canvas_layer.visible = show
	recipe_tab.visible = show

#================== PAUSE ======================

func pause(pause : bool):
	pause_menu.toggle_visible(true)
