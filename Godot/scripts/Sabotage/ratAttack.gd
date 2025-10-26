extends Node

@onready var mischief := []

@export var rat_scene : PackedScene = preload("res://scripts/Sabotage/rat.tscn")

var speed := 3.0

var count = 0
var secs = 2
var object_path
var target_path
var rat_targets := {} 
var teamID

var starting_pos := {}
var rat_states := {} # {rat: "going" or "returning"}

func _ready() -> void:
	pass

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

			if rat_targets[r] == NodePath(""):
				print("Rat has empty target path, returning home")
				rat_states[r] = "returning"
				continue
				
			var target_node = get_node(rat_targets[r]) 
			# if the target node is null, just continue
			# maybe make them run back to their spawn point instead
			if target_node == null:
				continue 
				
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
				target_node.take_food()
				var food = null
				if "contents" in target_node and target_node.contents.size() > 0:
					food = target_node.contents[0]
					ReputationSystem.minus_reputation(teamID % 2 + 1, 2)
					print("jess: rat got your food and now you lose some rep !")

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

# Change the state of the rat to go back home when their time runs out
func change_state() -> void:
	for r in mischief:
		rat_states[r] = "returning"
