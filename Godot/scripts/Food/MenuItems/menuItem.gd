extends Node3D
class_name MenuItem

@export var cooked_mesh_good: MeshInstance3D
@export var cooked_mesh_bad: MeshInstance3D
@export var cooked_mesh_burnt: MeshInstance3D
@export var ui_texture: Texture2D

var ingredients = []
var ingredient_states = {}
var name_of_meal : String
var ui_meal_name : String
var cost : int = 100
var diffuculty : int = 1
var ui_states : Dictionary = {}
var is_available = false
var quality = 1
#var appliance : String = "Plate"
# A MenuItem needs an Array of ingredients to combine together to make it
# They need to be able to add things together in a bowl/plate/pan etc. to make the menuItem
# do you need to be able to cook these?? or are you putting them together after they are cooked??

static var subclasses = []
static var starters = []
static var mains = []
static var deserts = []

static func _ensure_initialized():
	if subclasses == null:
		subclasses = []
	if starters == null:
		starters = []
	if mains == null:
		mains = []
	if deserts == null:
		deserts = []

static func register(subclass_class):
	_ensure_initialized()
	subclasses.append(subclass_class)

static func register_type(list_name: Array, food_item):
	_ensure_initialized()
	list_name.append(food_item)

static func get_subclasses() -> Array:
	return subclasses

func get_meal_name():
	return name_of_meal

# Needs to check if the list matches any of the MenuItems
func match_menu_items(input_ingredients: Array):
	#print("in match menu")
	for subclass in subclasses:
		var instance = subclass.new()
		input_ingredients.sort()
		instance.ingredients.sort()
		print("INPUTTTTT INGREDIENTS   ",input_ingredients)
		print("INSTANCE INGREDIENTS    ",instance.ingredients)
		if check_items(input_ingredients, instance.ingredients, instance):
			return instance 
	#print("there is no menu item that contains these ingredients")
	return null


	# This checks if the ingredient list passed matches the ingredient list we have
func check_items(pass_ingredients: Array, required_ingredients: Array, food_instance: MenuItem) -> bool:
	#print("in check items")
	if pass_ingredients.size() != required_ingredients.size():
		# print("Size mismatch - returning false")
		return false
	
	var required_counts = {}
	for r in required_ingredients:
		required_counts[r] = required_counts.get(r, 0) + 1
	
	var passed_counts = {}
	for passed in pass_ingredients:
		var ingredient_name = passed.food_name
		passed_counts[ingredient_name] = passed_counts.get(ingredient_name, 0) + 1
	
	for passed in pass_ingredients:
		var ingredient_name = passed.food_name
		#print("Checking ingredient: ", ingredient_name)
		
		if required_counts.get(ingredient_name, 0) == 0:
			#print("Ingredient not required or count exceeded: ", ingredient_name)
			return false
			
		if !check_states(passed, food_instance):
			#print("States check failed for: ", ingredient_name)
			return false
			
		required_counts[ingredient_name] -= 1 
	return true


func check_states(input_ingredient: Food, food_instance: MenuItem)->bool:
	var ingredient_name = input_ingredient.food_name
	var input_states = input_ingredient.previous_states
	var required_states = food_instance.ingredient_states[ingredient_name]
	
	# Check if the ingredient has been through ALL of the required states
	for required_state in required_states:
		if required_state not in input_states:
			#print("Missing required state: ", required_state)
			return false
	return true

func mesh_visibility(name: MeshInstance3D, turn_on: bool):
	name.visible = turn_on

func set_quality(new_quality):
	quality = new_quality

func get_quality():
	return quality
