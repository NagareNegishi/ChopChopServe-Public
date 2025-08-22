# sabotageSystem.gd
extends Node

signal sabotage_success(sabotage_type: String)
signal sabotage_failed(reason: String)

var sabotage_costs = {
	"crate_switch": 400,
	"water_spill": 450,
	"fire": 600,
	"food_critic": 700,
	"rat_swarm": 900,
	"power_outage": 1200,
}

func request_sabotage(sabotage_type: String) -> void:
	var cost = sabotage_costs[sabotage_type]
	var currency_system = $CurrencySystem
	var reputation_system = $ReputationSystem

	if not currency_system.check_currency(-cost):
		sabotage_failed.emit("Not enough currency")
		return

	currency_system.minus_currency(cost)

	match sabotage_type:
		"crate_switch":
			print("crate stuff")
		"water_spill":
			spawn_water_spill(10.0)
		"fire":
			print("fire stuff")
		_:
			print("other sabotage")

	sabotage_success.emit(sabotage_type)

func spawn_water_spill(duration: float) -> void:
	var spill = preload("res://scripts/Sabotage/waterSpill.tscn").instantiate()
	get_tree().get_current_scene().add_child(spill)
	spill.global_position = get_random_spill_position()
	spill.start_timer(duration)

func get_random_spill_position() -> Vector3:
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return Vector3.ZERO
	var target = players.pick_random()
	var pos = target.global_transform.origin
	pos.x += randf_range(-2, 2)
	pos.z += randf_range(-2, 2)
	return pos