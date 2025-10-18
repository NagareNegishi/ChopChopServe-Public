class_name UIRecipeIngred extends Control

const self_scene : PackedScene = preload("res://UI/Recipes/ui_recipe_ingredient.tscn")


static var chop = ResourceLoader.load("res://assets/textures/misc/meat-cleaver (3).png")
static var blend = ResourceLoader.load("res://assets/textures/misc/blender (2).png")

@onready var type_tex : TextureRect = $Type
@onready var food : TextureRect = $Ingredient

var _food_interact_type : String
var _food : String

static func create(type : String, food : String):
	var res : UIRecipeIngred = self_scene.instantiate()
	res._food_interact_type = type
	res._food = food
	return res
	

func _ready() -> void:
	match _food_interact_type:
		"MIXED":
			type_tex.texture = blend
		"CHOPPED":
			type_tex.texture = chop
		_:
			type_tex.texture = null

	var food_tex = ResourceLoader.load("res://assets/textures/ingredients/" + _food +".png")
	food.texture = food_tex
