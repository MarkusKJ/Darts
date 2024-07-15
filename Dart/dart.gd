extends RigidBody3D


@onready var hand: Generic6DOFJoint3D = $HandJoint
@onready var charge: ProgressBar = $DartUI/Charge


var is_rotating = false
var sensitivity = 0.01
var speed : float = 1.5
var direction: Vector3 = Vector3.FORWARD

func _ready():
	freeze = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(_delta: float) -> void:
	pass
	#charge.value += delta
	#position += direction * speed * delta



func _input(event: InputEvent) -> void:
	
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

func shoot():
	if is_instance_valid(hand):
		hand.queue_free()
		freeze = false
		var forward_direction = -global_transform.basis.z
		var impulse_strength = charge.value * speed  
		var impulse = forward_direction * impulse_strength
		apply_impulse(impulse)
	
func rotatedart():
	pass

func _integrate_forces(state):
	if is_rotating:
		state.angular_velocity = Vector3.ZERO
	
