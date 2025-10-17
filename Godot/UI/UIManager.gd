extends Node

signal recipe_ui_visible(is_visible : bool)

var load_screen : LoadingScreen
var recipe_screen : UIRecipe

@onready var canvas_layer : CanvasLayer = CanvasLayer.new()

func _ready() -> void:
	var load_scene : PackedScene = preload("res://UI/UI_LoadingScreen.tscn")
	load_screen = load_scene.instantiate()
	
	var recipe_scene : PackedScene = preload("res://UI/Recipes/UI_Recipe.tscn")
	recipe_screen = recipe_scene.instantiate()

	canvas_layer.visible = false
	canvas_layer.layer = 1000
	
	load_screen.visible = false
	recipe_screen.visible = false

	add_child(canvas_layer)
	canvas_layer.add_child(load_screen)
	canvas_layer.add_child(recipe_screen)
	
	recipe_screen.done.connect(_done)
	
	show_recipe(bolognese.new())


#================== LOADING SCREEN ======================


func play_load():
	_server_play_load.rpc()


@rpc("any_peer", "call_local")
func _server_play_load():
	if ENetManager.is_host(): return
	_client_play_load.rpc_id(1)


@rpc("authority", "call_local")
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
