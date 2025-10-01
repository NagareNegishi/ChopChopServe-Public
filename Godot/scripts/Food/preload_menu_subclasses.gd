extends Node

enum Ingredient{
	BEEF,
	CHICKEN,
	FISH,
	MILK,
	GARLIC,
	MUSHROOM,
	ONION,
	POTATO,
	APPLE,
	PINEAPPLE,
	TOMATO,
	PUMPKIN,
	COCOA,
	FLOUR,
	PASTA,
	CHEESE,
	DOUGH
}

const MESH = {
	Ingredient.GARLIC : preload("res://assets/newmodels/food/ingredients/raw/Garlic_Circle_003.res"),
	Ingredient.MUSHROOM : preload("res://assets/newmodels/food/ingredients/raw/Mushroom_Cube_031.res"),
	Ingredient.ONION : preload("res://assets/newmodels/food/ingredients/raw/Onion_Sphere_007.res"),
	Ingredient.POTATO : preload("res://assets/newmodels/food/ingredients/raw/Potato_Cube_027.res"),
	Ingredient.APPLE : preload("res://assets/newmodels/food/ingredients/raw/Apple_Icosphere_002.res"),
	Ingredient.PINEAPPLE : preload("res://assets/newmodels/food/ingredients/raw/Pineapple_Cube_024.res"),
	Ingredient.PUMPKIN : preload("res://assets/newmodels/food/ingredients/raw/Pumpkin_Sphere_009.res"),
	Ingredient.COCOA : preload("res://assets/newmodels/food/ingredients/raw/Cocoa_Cube_023.res"),
	Ingredient.FLOUR : preload("res://assets/newmodels/food/ingredients/raw/Flour_Cube_013.res"),
	Ingredient.PASTA : preload("res://assets/newmodels/food/ingredients/raw/Pasta_Cylinder_004.res"),
	Ingredient.CHEESE : preload("res://assets/newmodels/food/ingredients/raw/Cheese_Cube_020.res"),
	Ingredient.DOUGH : preload("res://assets/newmodels/food/ingredients/raw/Dough_Circle.res"),
	#Ingredient.TOMATO : preload("res://assets/models/food/ingredients/raw/BestTomato_Cube_076.res")

}
func _ready():
	preload("res://scripts/Food/MenuItems/bolognese.gd")
	preload("res://scripts/Food/MenuItems/bread.gd")
	preload("res://scripts/Food/MenuItems/brownie.gd")
	preload("res://scripts/Food/MenuItems/burger_beef.gd")
	preload("res://scripts/Food/MenuItems/burger_chicken.gd")
	preload("res://scripts/Food/MenuItems/burger_fish.gd")
	preload("res://scripts/Food/MenuItems/cheese_bread.gd")
	preload("res://scripts/Food/MenuItems/fish_and_chips.gd")
	preload("res://scripts/Food/MenuItems/garlic_bread.gd")
	preload("res://scripts/Food/MenuItems/icecream_chocolate.gd")
	preload("res://scripts/Food/MenuItems/icecream_strawberry.gd")
	preload("res://scripts/Food/MenuItems/icecream_vani.gd")
	preload("res://scripts/Food/MenuItems/mac_and_cheese.gd")
	preload("res://scripts/Food/MenuItems/onion_rings.gd")
	preload("res://scripts/Food/MenuItems/pie_apple.gd")
	preload("res://scripts/Food/MenuItems/pie_pineapple.gd")
	preload("res://scripts/Food/MenuItems/pie_pumpkin.gd")
	preload("res://scripts/Food/MenuItems/pizza_cheese.gd")
	preload("res://scripts/Food/MenuItems/pizza_hawaiian.gd")
	preload("res://scripts/Food/MenuItems/pizza_meat.gd")
	preload("res://scripts/Food/MenuItems/soup_mushroom.gd")
	preload("res://scripts/Food/MenuItems/soup_onion.gd")
	preload("res://scripts/Food/MenuItems/soup_pumpkin.gd")
	preload("res://scripts/Food/MenuItems/soup_tomato.gd")
	preload("res://scripts/Food/MenuItems/steak_and_chips.gd")
	preload("res://scripts/Food/MenuItems/taco_beef.gd")
	preload("res://scripts/Food/MenuItems/taco_chicken.gd")
	preload("res://scripts/Food/MenuItems/taco_mushroom.gd")
	#preload("res://scripts/Food/MenuItems/pancakes.gd")
	
