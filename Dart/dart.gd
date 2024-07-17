extends RigidBody3D


@onready var handmesh: StaticBody3D = $Hand
@onready var hand: Generic6DOFJoint3D = $HandJoint
@onready var charge: ProgressBar = $DartUI/Charge

#DartVariables
var sensitivity: float = 0.01
var speed : float = 4
var direction: Vector3 = Vector3.FORWARD
#DartStates
var is_rotating: bool = false
var has_been_shot: bool = false
var has_collided: bool = false

func _ready():
	freeze = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if has_been_shot:
		return
	
	#rotating the dart
	if event.is_action_pressed("leftmouse"):
		is_rotating = true
	elif event.is_action_released("leftmouse"):
		is_rotating = false
	if is_rotating and event is InputEventMouseMotion:
		var rotation_x = -event.relative.y * sensitivity
		var rotation_y = -event.relative.x * sensitivity
		
		rotate_object_local(Vector3.RIGHT, rotation_x)
		rotate_y(rotation_y)
	#charging the power of dart
	if event.is_action_pressed("Shoot"):
		print("charging")
		charge.value = 0
		charge.visible = true
	if event.is_action_released("Shoot"):
		print("shoot")
		shoot()
		charge.visible = false
#shooting the dart
func shoot():
	if is_instance_valid(hand):
		hand.queue_free()
		handmesh.queue_free()
		freeze = false
		var forward_direction = -global_transform.basis.z
		var impulse_strength = charge.value * speed  
		var impulse = forward_direction * impulse_strength
		apply_impulse(impulse)
		has_been_shot = true

func _integrate_forces(state):
	if is_rotating and not has_been_shot:
		state.angular_velocity = Vector3.ZERO


func _on_body_entered(body: Node):
	if has_been_shot and not has_collided:
		has_collided = true
		if not body.is_in_group("dartboard_sectors"):
			queue_free()
		else:
			pass
