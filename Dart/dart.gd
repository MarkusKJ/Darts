extends RigidBody3D

signal dart_miss
signal dart_thrown

@onready var dart_cams: Node3D = $DartCams
@onready var hand_cam: Camera3D = $DartCams/HandCam
@onready var dart_cam: Camera3D = $DartCams/CamSpring/DartCam
@onready var dart_col: CollisionShape3D = $DartCol
@onready var handmesh: StaticBody3D = $Hand
#DARTUI
@onready var dart_ui: CanvasLayer = $DartUI
@onready var reticle: CenterContainer = $DartUI/Control/Reticle
@onready var charge: ProgressBar = $DartUI/Control/Charge
#MULTIPLAYER

#DartVariables
#rotation
var sensitivity: float = 0.01
var smoothness: float = 30.0
var target_rotation = Vector3.ZERO
var current_rotation = Vector3.ZERO
var max_rotation_x = deg_to_rad(45)  # 45 degrees up and down
var max_rotation_y = deg_to_rad(90)  # 90 degrees left and right
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
	# Ensure initial rotation is within limits
	target_rotation.x = clamp(target_rotation.x, -max_rotation_x, max_rotation_x)
	target_rotation.y = clamp(target_rotation.y, -max_rotation_y, max_rotation_y)
	current_rotation = target_rotation
	

func _input(event: InputEvent) -> void:
	if Network.is_my_turn() and !has_been_shot:
		
		#rotating the dart
		if event.is_action_pressed("leftmouse"):
			is_rotating = true
		elif event.is_action_released("leftmouse"):
			is_rotating = false
		if is_rotating and event is InputEventMouseMotion:
			target_rotation.x -= event.relative.y * sensitivity
			target_rotation.y -= event.relative.x * sensitivity
			
			# Clamp the rotation
			target_rotation.x = clamp(target_rotation.x, -max_rotation_x, max_rotation_x)
			target_rotation.y = clamp(target_rotation.y, -max_rotation_y, max_rotation_y)
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
	else:
		return
		
func _process(delta):
	if Network.is_my_turn() and !has_been_shot:
		# Smoothly interpolate current rotation towards target rotation
		current_rotation = current_rotation.lerp(target_rotation, smoothness * delta)
		
		# Apply the smoothed rotation
		rotation.x = current_rotation.x
		rotation.y = current_rotation.y
	else:
		return
#shooting the dart
func shoot():
	if Network.is_my_turn():
		handmesh.queue_free()
		dart_cam.current = true
		freeze = false
		var forward_direction = -global_transform.basis.z
		var up_direction = global_transform.basis.y
		var impulse_strength = charge.value * speed
		var forward_impulse = forward_direction * impulse_strength
		var up_impulse = up_direction * (impulse_strength * 0.2)  # Adjust the 0.2 factor to change the arc height
		apply_impulse(forward_impulse + up_impulse)
		has_been_shot = true
		emit_signal("dart_thrown")
	else:
		print("Tried to shoot on !player turn")

func _integrate_forces(state):
	if is_rotating and not has_been_shot:
		state.angular_velocity = Vector3.ZERO
	elif has_been_shot:
		var velocity = state.linear_velocity
		if velocity.length() > 0.1:  # Only rotate if the dart is moving
			var aim_rotation = Basis.looking_at(velocity.normalized(), Vector3.UP)
			var cur_rotation = state.transform.basis
			var interpolated_rotation = cur_rotation.slerp(aim_rotation, 0.005)  # Adjust the 0.1 factor to change rotation speed
			state.transform.basis = interpolated_rotation
	else:
		return


func _on_body_entered(body: Node):
	if has_been_shot and not has_collided:
		has_collided = true
		if not body.is_in_group("dartboard_sectors"):
			#print("MISS")
			emit_signal("dart_miss")
		else:
			pass

