extends VBoxContainer

var multiplayer_peer = ENetMultiplayerPeer.new()

var connected_peer_ids = []

func _on_start_pressed() -> void:
	multiplayer_peer.create_server(
		$Menu/PortInput.text.to_int(),
		$Menu/MaxPlayersInput.text.to_int()
	)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	
	multiplayer_peer.peer_connected.connect(
		func(new_peer_id):
			await get_tree().create_timer(1).timeout
			rpc_id(new_peer_id, "add_previously_connected_players", connected_peer_ids)
			
			rpc("add_newly_connected_player", new_peer_id)
			add_player(new_peer_id)
		
	)
	$Menu.visible = false

func add_player(peer_id):
	connected_peer_ids.append(peer_id)
	var player = preload("res://Scripts/Main/player.tscn").instantiate()
	player.set_multiplayer_authority(peer_id)
	add_child(player)


@rpc('call_remote')
func add_newly_connected_player(new_peer_id):
	pass
	
@rpc('call_remote')
func add_previously_connected_player(peer_ids):
	pass
