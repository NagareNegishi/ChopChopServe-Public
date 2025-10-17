extends Node
#class_name Rat

################################################################################
# TODO:
	# - Make them avoid objects
	# - increase timer duration
	# - Do something about their spawn points
	# - Make the targets the other teams stuff
	# - Make then look for, and pick up the food items instead
	# - Make them animated
	# - Change the going home logic so that it is smoother (return home, not just disapear)
	# - Fix code up
################################################################################



@onready var mischief := []

@export var rat_scene : PackedScene = preload("res://scripts/Sabotage/rat.tscn")

var speed := 3.0 # Units per second

var count = 0
var secs = 2
var object_path
var target_path
var rat_targets := {} 
var teamID

var starting_pos := {}
var rat_states := {} # {rat: "going" or "returning"}

# Is there a way to initshate the rat assest?
# how do I do that ??

# Here I need to code the Rats movement
# its position
# inistating it within the scene
# a searching algorithim to find the objects on the bench
# path finding stuff
# update its image
# be able to be effected by rat spray? (is this still happening)
# 

# spawn every 2 seconds from grates in the kitchen
# roam to the closest bench that has an item
# no two rats can target the same item
# once they grab an item they will run back to their grate
# and disopare with their item in hand
# they can be attacked by rat spray (maybe make it the fire eughnisuisah)
# the spray will kill them, dropping the item in their hand
# lasts 20s before the rats stop spawning

func _ready() -> void:
	pass

# Should I move this stuff into the Rat script??
func _process(delta: float) -> void:
	run(delta)

# Make the Rats run towards something
# currently just a random spot on the screen
func run(delta: float):
	for r in mischief:
		if not is_instance_valid(r):
			continue
		
		if rat_states.get(r, "going") == "going":
			if not rat_targets.has(r):
				continue

			var target_node = get_node(rat_targets[r]) 
			# if the target node is null, just continue
			# maybe make them run back to their spawn point instead
			if target_node == null:
				continue 
			#find_object() #Vector3(10, 0, 10) # example target
			var target_pos = target_node.global_position
			var old_pos = r.global_position
			var new_pos = r.global_position.move_toward(target_pos, speed * delta)
		
			# update position
			r.global_position = new_pos
		
			# calculate movement direction
			var dir = (new_pos - old_pos).normalized()
			if dir.length() > 0.01:
				r.look_at(new_pos - dir, Vector3.UP)
			
			if r.global_position.distance_to(target_pos) < 0.1:
				print("bran: found my target, time to go home")

				target_node.take_food()
				var food = null
				if "contents" in target_node and target_node.contents.size() > 0:
					food = target_node.contents[0]

				if food and is_instance_valid(food):
					var parent = food.get_parent()
					if parent:
						parent.remove_child(food)
					r.add_child(food)
					food.position = Vector3(0, 0.2, 0)
				
				rat_states[r] = "returning"
				rat_targets.erase(r)


		elif rat_states.get(r) == "returning":
			var start_pos = starting_pos.get(r, Vector3.ZERO)
			var old_pos = r.global_position
			var new_pos = r.global_position.move_toward(start_pos, speed * delta)
			r.global_position = new_pos
			var dir = (new_pos - old_pos).normalized()
			if dir.length() > 0.01:
				r.look_at(new_pos - dir, Vector3.UP)
			if r.global_position.distance_to(start_pos) < 0.1:
				print("rat returned home, removing")
				r.queue_free()
				mischief.erase(r)
				rat_states.erase(r)
				starting_pos.erase(r)

			
# Maybe add a variable to decide the amount of rats
func spawn_rat_mischief(team_id: int, position : Vector3, path : NodePath) -> void:
	#for i in range(1, 5):
	var new_rat = rat_scene.instantiate()
	add_child(new_rat)		
	new_rat.global_position = position
	#object_path = path
	mischief.append(new_rat)
	#position.x += 1
	# assign a target
	rat_targets[new_rat] = path
	starting_pos[new_rat] = position
	rat_states[new_rat] = "going"
	#start_timer(secs)
	#new_rat.rat_timer()
	#new_rat.set_team_id(team_id)
	#var start = get_tree().get_current_scene()
	#var bs : Array = find_benches(start)
	#print("benches in the scene ======= ", bs)
	#teamID = team_id

# Change the state of the rat to go back home when their time runs out
func change_state() -> void:
	for r in mischief:
		rat_states[r] = "returning"
