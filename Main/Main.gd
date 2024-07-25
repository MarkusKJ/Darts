extends Node


func _ready():
	Network.game_state_updated.connect(self._on_game_state_updated)
	
	if OS.has_feature("dedicated_server"):
		Network.start_server()
	else:
		Network.start_client()

func _process(_delta):
	if multiplayer.is_server() or multiplayer.get_unique_id() == Network.current_player:
		# Update game state
		var new_dart_position = $Dart.global_transform.origin
		var new_score = calculate_score()
		
		# Send updates to server (or to all clients if we are the server)
		Network.send_game_state.rpc(new_dart_position, new_score, Network.current_player)

func _on_game_state_updated():
	# Update game objects based on new state
	$Player.global_transform.origin = Network.player_position
	$Dart.global_transform.origin = Network.dart_position
	update_score_display(Network.current_score)
	update_current_player_display(Network.current_player)

func calculate_score():
	# Your score calculation logic here
	pass

func update_score_display(score):
	# Update UI with new score
	pass

func update_current_player_display(player):
	# Update UI to show whose turn it is
	pass
