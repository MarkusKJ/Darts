extends Node3D
const DART_MESH = preload('res://Scenes/Darts/dart_mesh.tscn')
const dart = preload('res://Scenes/Darts/dart.tscn')

@onready var player_cam: Camera3D = $PlayerCam
@export var dartboard: Node3D


const camera_pos = Vector3(1.45, 21.926, -3.829)
const dart_posi = Vector3(1.806,19.458,-7.115)


const pos_y = Vector3(0, 30, 0)
var dart_pos = Vector3.ZERO
var max_darts: int = 3 
var active_darts: Array = []
var current_dart: RigidBody3D
var can_spawn_new_dart: bool = true

func _ready():
	player_cam.position = camera_pos
	player_cam.current = true
	spawn_new_dart()

func spawn_new_dart():
	if active_darts.size() >= max_darts or not can_spawn_new_dart:
		print("Cannot spawn new dart")
		return null
	
	# Replace the previous dart with its mesh
	if current_dart:
		replace_dart_with_mesh(current_dart)
	
	current_dart = dart.instantiate()
	add_child(current_dart)
	active_darts.append(current_dart)
	
	current_dart.connect("dart_miss", Callable(self, "on_dart_miss").bind(current_dart))
	current_dart.connect("dart_thrown", Callable(self, "on_dart_thrown"))
	
	current_dart.position = get_initial_dart_transform()
	can_spawn_new_dart = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("spawn") and can_spawn_new_dart:
		spawn_new_dart()
		
func get_initial_dart_transform() -> Vector3:
	return dart_posi

func replace_dart_with_mesh(_dart: RigidBody3D):
	var mesh_instance = DART_MESH.instantiate()
	mesh_instance.global_transform = _dart.global_transform
	add_child(mesh_instance)
	active_darts[active_darts.find(_dart)] = mesh_instance
	_dart.queue_free()

func on_dart_miss(missed_dart: RigidBody3D):
	if missed_dart in active_darts:
		active_darts.erase(missed_dart)
		missed_dart.freeze = true
		missed_dart.queue_free()
	if missed_dart == current_dart:
		current_dart = null
	
	can_spawn_new_dart = true
	spawn_new_dart()

func on_dart_thrown():
	can_spawn_new_dart = true

func _physics_process(_delta):
	if current_dart:
		dart_pos = current_dart.global_transform.origin
