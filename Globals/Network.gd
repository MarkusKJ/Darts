extends Node

var dart_position = Vector3(0,30,0)
var current_score: int = 0
var current_player: int = 1
const PLAYER = preload("res://Scenes/Main/Player.tscn") 
var players: Dictionary = {}
var player_order: Array = []
var peer: ENetMultiplayerPeer
var server_ip: String = "127.0.0.1"
var server_port: int = 8910
var max_players: int = 4
var turns_per_player: int = 3
var current_turn: int = 1

signal game_state_updated
signal turn_changed(player_id: int)
signal game_over

func _ready():
	multiplayer.peer_connected.connect(self._on_peer_connected)
	multiplayer.peer_disconnected.connect(self._on_peer_disconnected)

func start_client():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(server_ip, server_port)
	if error:
		print("Error connecting to server: ", error)
		return
	multiplayer.multiplayer_peer = peer

func start_server():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(server_port, max_players)
	if error:
		print("Error starting server: ", error)
		return
	multiplayer.multiplayer_peer = peer
	players[1] = "Host"
	player_order.append(1)
	add_player(multiplayer.get_unique_id())

func add_player(peer_id):
	var player = PLAYER.instantiate()
	player.name = str(peer_id)
	add_child(player)
	players[peer_id] = "Player " + str(peer_id)
	if not peer_id in player_order:
		player_order.append(peer_id)
	print("Added player:", peer_id)
	if multiplayer.is_server():
		rpc("update_player_list", players, player_order)

@rpc("reliable")
func update_player_list(new_players: Dictionary, new_player_order: Array):
	players = new_players
	player_order = new_player_order
	if player_order.size() >= 2 and multiplayer.is_server():
		start_game()

@rpc("reliable")
func start_game():
	if multiplayer.is_server():
		current_player = player_order[0]
		current_turn = 1
		rpc("set_current_player", current_player, current_turn)

@rpc("reliable")
func set_current_player(player_id: int, turn: int):
	current_player = player_id
	current_turn = turn
	turn_changed.emit(current_player)

@rpc("any_peer", "reliable")
func end_turn():
	if multiplayer.is_server():
		var current_index = player_order.find(current_player)
		current_index = (current_index + 1) % player_order.size()
		current_player = player_order[current_index]
		
		if current_index == 0:
			current_turn += 1
		
		if current_turn > turns_per_player:
			rpc("call_game_over")
		else:
			rpc("set_current_player", current_player, current_turn)

@rpc("reliable")
func call_game_over():
	game_over.emit()
	print("Network GameOver")

@rpc("any_peer", "reliable")
func send_game_state(dart_pos: Vector3, score: int):
	dart_position = dart_pos
	current_score = score
	if multiplayer.is_server():
		rpc("update_game_state", dart_pos, score, current_player, current_turn)
		end_turn()
	game_state_updated.emit()
	print("Network send_game_state")

@rpc("reliable")
func update_game_state(dart_pos: Vector3, score: int, player: int, turn: int):
	dart_position = dart_pos
	current_score = score
	current_player = player
	current_turn = turn
	game_state_updated.emit()
	print("Network update_game_state")
	
@rpc("unreliable")
func sync_dart_position(dart_id: int, position: Vector3, velocity: Vector3):
	if not multiplayer.is_server():
		var dart = get_node_or_null("/root/GameScene/DartSpawner/Dart_" + str(dart_id))
		if dart:
			dart.global_transform.origin = position
			dart.linear_velocity = velocity

func _on_peer_connected(id):
	print("Peer connected: ", id)
	if multiplayer.is_server():
		add_player(id)

func _on_peer_disconnected(id):
	print("Peer disconnected: ", id)
	if multiplayer.is_server():
		players.erase(id)
		player_order.erase(id)
		rpc("update_player_list", players, player_order)
		if current_player == id:
			end_turn()

func is_my_turn() -> bool:
	return multiplayer.get_unique_id() == current_player
