extends Node
class_name Rat

@onready var mischief := []

@export var rat_scene : PackedScene = preload("res://scripts/Sabotage/rat.tscn")

var speed := 3.0 # Units per second

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
	print("HELLO I AM A RAT")

var count = 0
var secs = 5
var object_path

func _process(delta: float) -> void:
	run(delta)

# Make the Rats run towards something
# currently just a random spot on the screen
func run(delta: float):
	for r in mischief:
		if not is_instance_valid(r):
			continue
		if object_path == null:
			continue

		var target_node = get_node(object_path) 
		if target_node == null:
			continue#find_object() #Vector3(10, 0, 10) # example target
		var target_pos = target_node.global_position
		var old_pos = r.global_position
		var new_pos = r.global_position.move_toward(target_pos, speed * delta)
		
		# update position
		r.global_position = new_pos
		
		# calculate movement direction
		var dir = (new_pos - old_pos).normalized()
		if dir.length() > 0.01:
			# point the rat's nose (Z+) toward movement
			r.look_at(new_pos - dir, Vector3.UP)
		target_node = NodePath("")
		target_pos = Vector3(0, 0, 0)
			
# Maybe add a variable to decide the amount of rats
func spawn_rat_mischief(position : Vector3, path : NodePath) -> void:
	for i in range(1, 5):
		var new_rat = rat_scene.instantiate()
		add_child(new_rat)
		new_rat.global_position = position
		object_path = path
		mischief.append(new_rat)
		position.x += 1
	start_timer(secs)
	#var start = get_tree().get_current_scene()
	#var bs : Array = find_benches(start)
	#print("benches in the scene ======= ", bs)

func get_all_positions() -> Array:
	var positions = []
	for rat in mischief:	
		if is_instance_valid(rat):		
			positions.append(rat.global_position)
	return positions

func cleanup_swarm():
	pass
	#mischief = mischief.filter(func(r): return is_instance_valid(r))

# Rat duration timer
func start_timer(seconds: float) -> void:
	var timer = Timer.new()
	timer.wait_time = seconds
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	#queue_free()
	print("done")
	#moving_rats()


# Add the Rats to the pack
func add_to_mischief(rat : MeshInstance3D):
	mischief.append(rat)
	count+1
	print("\n adding new RATTTTTTTTT : this is number: ", count)
	

func move_rat(rat : MeshInstance3D, position : Vector3) -> void:
	rat.global_position += position
	print("RAT NUMBER : ", mischief[rat], "MOVED")

func moving_rats():
	for r in mischief:
		r.global_position += Vector3(2, 0, 4)

func get_position():
	pass #print("=========== getting the rats ==============", mischief)

# This code currently works !!
func find_object() -> Vector3:#NodePath:
	#var bench_list : Array = []
	var object
	#print("is there an object within the scene they can get?")
	# Figure out how to figureout if there is an object on a bench within the scene
	var appliances = get_tree().get_nodes_in_group("flammable")
	print(appliances)
	for item in appliances:
		#print("going through #1")
		if item is Bench:
			#print("====this is a bench===== ", item)
			object = item.global_position
	return object
		
			
	# Need to figure out how this should actually work with propper stuff
	# But for now just ignore this
			#print("item and its contents ::::::: ", item.contents)
			#for b in item.contents:
			#	print("going through #2")
			#	if b is Food:
			#		print("====== this is a food item found ======== ", b)
				#bench_list.append(item)
				


		#if item.content.size() > 0:
		#	print("there is an item : ", item.content)

func find_benches(root: Node = null) -> Array:
	if root == null:
		root = get_tree().get_current_scene()

	print("finding benches")
	var benches : Array = []
	for child in root.get_children(): #.get_nodes_in_group("root"):
		print("child type ===== ", child.get_class_name())
		if child is Bench:
			print("found a bench")
			benches.append(child)
		benches.append_array(find_benches(child)) # recursive
	return benches
	
	
	#print("finding bench")
	#var benches = []
	#for node in get_tree().get_nodes_in_group("benches"): #get_tree().get_current_scene().get_children():
	#	print("node ===== ", node)
	#	if node is Bench:
	#		benches.append(node)
	#if benches.is_empty():
	#	print("No benches found!")
	#else:
	#	for b in benches:
	#		if b.contents.size() > 0:
	#			print("bench has something on it: ", b, " -> ", b.contents)
	#		else:
	#			print("bench is empty: ", b)
	
		# debug print
	#for b in benches:
	#	if b.contents != null and b.contents.size() > 0:
	#		print("bench has something on it: ", b, " -> ", b.contents)
	#	else:
	#		print("bench is empty: ", b)
		
	#for bench in benches:
	#	if bench.has_method("has_object") and bench.has_object():
	#		print("Bench", bench, "has an object!")
	#	elif bench.has("content") and bench.content != null:
	#		print("Bench", bench, "is holding", bench.content)
	#	else:
	##		print("Bench", bench, "is empty.")

	#if benches.size() == 0:
	#	print("no benches found")
	
	#for item in benches:
	#	if not item.content.is_empty():
	#		print("yay i found: ", item.content)
