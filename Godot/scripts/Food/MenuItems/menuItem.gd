extends Node3D
class_name MenuItem

@export var cooked_mesh_good: MeshInstance3D
@export var cooked_mesh_bad: MeshInstance3D
@export var cooked_mesh_burnt: MeshInstance3D

var ingredients = []
var ingredient_states = {}
var name_of_meal : String
var appliance : String = "Plate"
# A MenuItem needs an Array of ingredients to combine together to make it
# They need to be able to add things together in a bowl/plate/pan etc. to make the menuItem
# do you need to be able to cook these?? or are you putting them together after they are cooked??

static var subclasses = []

static func register_subclass(subclass):
	subclasses.append(subclass)

static func get_subclasses() -> Array:
	return subclasses

# Needs to check if the list matches any of the MenuItems
func match_menu_items(input_ingredients: Array):
	for subclass in subclasses:
		var instance = subclass.new()
		if check_items(input_ingredients, instance.ingredients, instance):
			return instance
	print("there is no menu item that contains these ingredients")
	return "no match"


# This checks if the ingredient list passed matches the ingredient list we have
func check_items(pass_ingredients: Array, required_ingredients: Array, food_instance:MenuItem) -> bool:
	if pass_ingredients.size() != required_ingredients.size():
		return false
	
	for passed in pass_ingredients:
		var name = passed.food_name
		if name == null:
			print("in check items, the passed ingredient doesnt have a name")
			return false
		if !required_ingredients.has(name):
			print("in check items, the required ingredients array doesnt contain the passed ingredient")
			return false
		if !check_states(passed, food_instance):
			print("in check items, the passed ingredient doesnt have the correct previosu states")
			return false
	
	return true


func check_states(input_ingredient: Food, food_instance: MenuItem)->bool:
	name = input_ingredient.food_name
	var input_states = input_ingredient.previous_states
	var required_states = food_instance.ingredient_states[name]
	
	for s in input_states:
		if !required_states.has(s):
			print("In check states, the required_state does n ot contain the state of the given ingredient")
			return false
	
	print("In check states, the required_state has the ingredient states")
	return true
