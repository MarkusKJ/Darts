extends Node3D
@onready var ray_cast: RayCast3D = $Dart/RayCast3D
@onready var crosshair: CenterContainer = $Dart/DartUI/Reticle
@onready var dart: RigidBody3D = $Dart

var collision_marker: MeshInstance3D

func _ready():
	# Create a MeshInstance3D for the collision marker
	collision_marker = MeshInstance3D.new()
	add_child(collision_marker)
	
	# Create a spherical mesh for the marker
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 1.0  # Adjust size as needed
	sphere_mesh.height = 2.0
	collision_marker.mesh = sphere_mesh
	
	# Create a material for the marker
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.RED
	collision_marker.material_override = material

func _process(_delta):
	if ray_cast.is_colliding() and dart.is_rotating:
		var collision_point = ray_cast.get_collision_point()
		update_collision_marker(collision_point)
	else:
		collision_marker.visible = false

func update_collision_marker(position: Vector3):
	collision_marker.global_position = position
	collision_marker.visible = true
