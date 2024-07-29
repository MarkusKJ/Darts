extends Node

signal player_connected(id)
signal game_state_updated
signal turn_changed(player_id)
signal game_over

var is_server: bool = false
var players = {}
var current_player_turn: int = 1

func start_server():
	is_server = true
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(4242)
	multiplayer.multiplayer_peer = peer
	printerr("DEBUG: Server started on port 4242")

func start_client():
	is_server = false
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("localhost", 4242)
	multiplayer.multiplayer_peer = peer
	printerr("DEBUG: Client connected to localhost:4242")

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	printerr("DEBUG: Node is ready, connections set up")

func _on_peer_connected(id):
	players[id] = "Player " + str(id)
	printerr("DEBUG: Peer connected with ID:", id)
	if is_server:
		emit_signal("player_connected", id)
		printerr("DEBUG: Emitted player_connected signal for ID:", id)

func _on_peer_disconnected(id):
	players.erase(id)
	printerr("DEBUG: Peer disconnected with ID:", id)

@rpc("authority", "call_local")
func start_game():
	# Initialize game state, set up first turn, etc.
	printerr("DEBUG: Game started")
	pass

func is_my_turn() -> bool:
	var is_turn = multiplayer.get_unique_id() == current_player_turn
	printerr("DEBUG: Is my turn?", is_turn, "Current turn:", current_player_turn)
	return is_turn


# ... (other network-related functions)
