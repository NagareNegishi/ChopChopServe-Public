class_name FoodCrateCat
extends Control

@onready var main : TextureRect = $Main
@onready var next : TextureRect = $Next


var index : int = 0
var _textures = [preload("res://assets/textures/ingredients/ham.png"), 
				preload("res://assets/textures/ingredients/mushroom.png"), 
				preload("res://assets/textures/ingredients/apple.png"), 
				preload("res://assets/textures/ingredients/cheese.png")]


func _ready():
	main.texture = _textures[index]
	next.texture = _textures[index + 1]
	

func next_cat():
	index = index + 1 if index + 1 < _textures.size() else 0
	main.texture = _textures[index]
	next.texture = _textures[index + 1 if index < _textures.size() - 1 else 0]
