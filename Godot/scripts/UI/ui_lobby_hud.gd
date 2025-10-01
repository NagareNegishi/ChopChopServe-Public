extends Control

@onready var list : Array[Control] = [$PlayerList/P1, $PlayerList/P2, $PlayerList/P3, $PlayerList/P4]
@onready var collect_text : Label = $Collectables/Label
var total : int 
var collectibles : Array[Node]
var _collect_count : int = -1

func _ready() -> void:
	$Server.text = "Client" if !multiplayer.is_server() else "Server"
	
	await get_tree().create_timer(0.1).timeout
	_load_players()
	collectibles = get_tree().get_nodes_in_group("Collectible")
	for c in collectibles:
		if c is Collectible:
			c.collected.connect(set_collect_text)

	total = collectibles.size() - 1
	set_collect_text(null)
	

func _load_players():
	var players : Array[int] = ENetManager.get_player_list()
	players.sort_custom(sort_team)
	for i in range(list.size()):
		if i >= players.size(): 
			list[i].visible = false
			continue
		
		list[i].get_node("Player").set_from_id(players[i], i)


func set_collect_text(collectible : Collectible):
	_collect_count += 1
	collect_text.text = str(_collect_count)+"/"+str(max(total,0))
	

func sort_team(a,b) -> bool: 
	return !ENetManager.get_team1().has(a) 
