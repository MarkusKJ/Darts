extends Camera3D

@export var dart: RigidBody3D
@export var min_fov: float = 25.0
@export var max_fov: float = 120.0
@export var fov_change_duration: float = 1.8
@export var min_velocity_threshold: float = 0.1

var initial_fov: float
var fov_change_timer: float = 0.0

@export var dart_aim_sens = 0.0025

func _ready():
	initial_fov = min_fov
	fov = initial_fov

func _physics_process(delta):
	if self.current:
		dart.sensitivity = dart_aim_sens
	if dart and dart.has_been_shot:
		var current_velocity = dart.linear_velocity.length_squared()
		
		if current_velocity > min_velocity_threshold and fov < max_fov:
			fov_change_timer += delta
			fov = min(max_fov, lerp(min_fov, max_fov, fov_change_timer / fov_change_duration))
		elif self.fov == max_fov:
			pass
			#fov_change_timer = fov_change_duration
