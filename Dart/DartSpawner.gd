extends Node3D

@onready var dartloader: ResourcePreloader = $Dartloader
@onready var timer: Timer = $Timer
@export var dartboard: Node3D
const pos_y = Vector3(0, 30, 0)
var dart_pos = Vector3.ZERO
var max_darts: int = 44 
var active_darts: Array = []
var current_dart: RigidBody3D
var can_spawn_new_dart: bool = true

func _ready():
	pass

func spawn_new_dart():
	if active_darts.size() >= max_darts or not can_spawn_new_dart:
		print("Cannot spawn new dart")
		return null
	
	if current_dart:
		replace_dart_with_mesh(current_dart)
	
	var new_dart = dartloader.get_resource("dart").instantiate()
	new_dart.name = "Dart_" + str(Network.multiplayer.get_unique_id())
	add_child(new_dart)
	active_darts.append(new_dart)
	
	new_dart.connect("dart_miss", Callable(self, "on_dart_miss").bind(new_dart))
	new_dart.connect("dart_thrown", Callable(self, "on_dart_thrown"))
	
	new_dart.position = get_initial_dart_transform()
	
	current_dart = new_dart
	can_spawn_new_dart = false

	if Network.multiplayer.is_server():
		Network.rpc("sync_dart_spawn", new_dart.name, new_dart.position)

	return new_dart
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("spawn") and can_spawn_new_dart:
		#if multiplayer.is_server() or multiplayer.get_unique_id() == Network.current_player:
		spawn_new_dart()

func get_initial_dart_transform() -> Vector3:
	return pos_y

func replace_dart_with_mesh(dart: RigidBody3D):
	dart.queue_free()

@rpc("any_peer", "call_local")
func on_dart_miss(missed_dart: RigidBody3D):
	if missed_dart in active_darts:
		active_darts.erase(missed_dart)
		missed_dart.freeze = true
		missed_dart.queue_free()
	if missed_dart == current_dart:
		current_dart = null
	
	can_spawn_new_dart = true
	if multiplayer.is_server():
		spawn_new_dart()

@rpc("any_peer", "call_local")
func on_dart_thrown():
	can_spawn_new_dart = true
