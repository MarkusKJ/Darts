extends Node3D

@onready var dartloader: ResourcePreloader = $Dartloader
@export var dartboard: Node3D
const pos_y = Vector3(0, 30, 0)
var dart_pos = Vector3.ZERO
var max_darts: int = 3 
var active_darts: Array = []
var current_dart: RigidBody3D
var can_spawn_new_dart: bool = true

func _ready():
	spawn_new_dart()

func spawn_new_dart():
	if active_darts.size() >= max_darts or not can_spawn_new_dart:
		print("Cannot spawn new dart")
		return null
	
	# Replace the previous dart with its mesh
	if current_dart:
		replace_dart_with_mesh(current_dart)
	
	var new_dart = dartloader.get_resource("dart")
	current_dart = new_dart.instantiate()
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
	return pos_y

func replace_dart_with_mesh(dart: RigidBody3D):
	var mesh_instance = dartloader.get_resource("dart_mesh").instantiate()
	mesh_instance.global_transform = dart.global_transform
	add_child(mesh_instance)
	active_darts[active_darts.find(dart)] = mesh_instance
	dart.queue_free()

func on_dart_miss(missed_dart: RigidBody3D):
	if missed_dart in active_darts:
		active_darts.erase(missed_dart)
		missed_dart.queue_free()
	
	if missed_dart == current_dart:
		current_dart = null
	
	can_spawn_new_dart = true

func on_dart_thrown():
	can_spawn_new_dart = true

func _physics_process(_delta):
	if current_dart:
		dart_pos = current_dart.global_transform.origin
