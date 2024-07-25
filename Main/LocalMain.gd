extends Node3D

@onready var dartspawner = $DartSpawner  # Assuming you have a DartSpawner node
@onready var dartboard: Node3D = $dartboard

#NetworkUI
@onready var nsdisp: Label = $NetworkCanvas/CC/NetworkInfo/NetworkSideDisplay
@onready var uniqpid: Label = $NetworkCanvas/CC/NetworkInfo/UniquePeerID
@onready var menu: VBoxContainer = $NetworkCanvas/CC/Menu
@onready var spawn: Button = $NetworkCanvas/CC/Menu/Spawn


var current_score = Network.current_score

func _ready():
	Network.game_state_updated.connect(self._on_game_state_updated)
	Network.turn_changed.connect(self._on_turn_changed)
	Network.game_over.connect(self._on_game_over)
	# Connect to dartboard's signals
	dartboard.connect("darthit", Callable(self, "_on_dart_hit"))

#-----------------------------------------------------
#NETWORKUI
func _on_host_pressed() -> void:
	nsdisp.text = "Server"
	#menu.visible = false
	Network.start_server()
	uniqpid.text = str(multiplayer.get_unique_id())

func _on_join_pressed() -> void:
	nsdisp.text = "Client"
	#menu.visible = false
	Network.start_client()
	uniqpid.text = str(multiplayer.get_unique_id())
	
#-----------------------------------------------------
	

func _on_turn_changed(player_id: int):
	if Network.is_my_turn():
		print("It's your turn!")
		dartspawner.spawn_new_dart()
	else:
		print("It's " + Network.players[player_id] + "'s turn")
		

func enable_controls():
	dartspawner.spawn_new_dart()


func _on_game_state_updated():
	# Update game objects based on new state
	current_score = Network.current_score
	# Update score display, etc.
	
func _on_game_over():
	print("gameover")

#Sketchy
func _on_dart_hit(score: int, position: Vector3):
	current_score += score
	var dart_position = dartspawner.current_dart.global_transform.origin
	Network.send_game_state.rpc(dart_position, current_score)
	Network.end_turn.rpc()


func _on_spawn_pressed() -> void:
	dartspawner.spawn_new_dart()


func _on_register_pressed() -> void:
	Network.register_player("j")
