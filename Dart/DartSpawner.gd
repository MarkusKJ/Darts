extends Node3D

@onready var dartloader: ResourcePreloader = $Dartloader

const pos_y = Vector3(0,30,0)

var current_dart: RigidBody3D

func _ready():
	spawn_new_dart()

func spawn_new_dart():
	var dart_scene = dartloader.get_resource("dart")
	current_dart = dart_scene.instantiate()
	self.add_child(current_dart)
	# Set initial position, rotation, etc. for the new dart
	current_dart.global_position = get_initial_dart_transform()

func _on_dart_shot():
	# This function would be called when a dart is shot
	# Wait for a short delay, then spawn a new dart
	await get_tree().create_timer(0.5).timeout
	spawn_new_dart()

func get_initial_dart_transform() -> Vector3:
	# Return the initial transform for the dart
	# This could be a fixed position or based on some game logicv
	return pos_y # Replace with actual initial transform
