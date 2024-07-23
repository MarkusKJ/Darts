extends RigidBody3D

signal dart_miss
signal dart_thrown

@onready var dart_cams: Node3D = $DartCams
@onready var hand_cam: Camera3D = $DartCams/HandCam
@onready var dart_cam: Camera3D = $DartCams/CamSpring/DartCam
@onready var reticle: CenterContainer = $DartUI/Reticle

@onready var handmesh: StaticBody3D = $Hand
@onready var hand: Generic6DOFJoint3D = $HandJoint
@onready var charge: ProgressBar = $DartUI/Charge

#DartVariables
#rotation
var sensitivity: float = 0.01
var smoothness: float = 30.0
var target_rotation = Vector3.ZERO
var current_rotation = Vector3.ZERO
#physics
var speed : float = 4
var direction: Vector3 = Vector3.FORWARD
#DartStates
var is_rotating: bool = false
var has_been_shot: bool = false
var has_collided: bool = false

func _ready():
	hand_cam.current = true
	freeze = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#rotation init
	target_rotation = rotation
	current_rotation = rotation
	

func _input(event: InputEvent) -> void:
	if has_been_shot:
		return
	
	#rotating the dart
	if event.is_action_pressed("leftmouse"):
		is_rotating = true
	elif event.is_action_released("leftmouse"):
		is_rotating = false
	if is_rotating and event is InputEventMouseMotion:
		target_rotation.x -= event.relative.y * sensitivity
		target_rotation.y -= event.relative.x * sensitivity
		
		#rotate_object_local(Vector3.RIGHT, rotation_x)
		#rotate_y(rotation_y)
	#charging the power of dart
	if event.is_action_pressed("Shoot"):
		print("charging")
		charge.value = 0
		charge.visible = true
	if event.is_action_released("Shoot"):
		print("shoot")
		shoot()
		reticle.visible = false
		charge.visible = false
		
func _process(delta):
	if not has_been_shot:
		# Smoothly interpolate current rotation towards target rotation
		current_rotation = current_rotation.lerp(target_rotation, smoothness * delta)
		
		# Apply the smoothed rotation
		rotation.x = current_rotation.x
		rotation.y = current_rotation.y
#shooting the dart
func shoot():
	if is_instance_valid(hand):
		hand.queue_free()
		handmesh.queue_free()
		dart_cam.current = true
		freeze = false
		var forward_direction = -global_transform.basis.z
		var impulse_strength = charge.value * speed  
		var impulse = forward_direction * impulse_strength
		apply_impulse(impulse)
		has_been_shot = true
		emit_signal("dart_thrown")

func _integrate_forces(state):
	if is_rotating and not has_been_shot:
		state.angular_velocity = Vector3.ZERO


func _on_body_entered(body: Node):
	if has_been_shot and not has_collided:
		has_collided = true
		if not body.is_in_group("dartboard_sectors"):
			print("MISS")
			emit_signal("dart_miss")
		else:
			pass

