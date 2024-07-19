extends Camera3D

@export var sensitivity: float = 0.01
@export var min_angle: float = -90
@export var max_angle: float = 45
@export var smoothness: float = 10.0  # Controls how smooth the rotation is (higher = smoother)

@onready var spring_arm: SpringArm3D = get_parent()

var target_rotation = Vector3.ZERO
var current_rotation = Vector3.ZERO

func _ready():
	# Initialize the rotations
	target_rotation = spring_arm.rotation
	current_rotation = spring_arm.rotation

func _input(event: InputEvent):
	if not current:
		return
	if event is InputEventMouseMotion:
		# Update target rotation based on mouse input
		target_rotation.y -= deg_to_rad(event.relative.x * sensitivity)
		target_rotation.x -= deg_to_rad(event.relative.y * sensitivity)
		
		# Clamp the vertical rotation
		target_rotation.x = clamp(target_rotation.x, deg_to_rad(min_angle), deg_to_rad(max_angle))

func _process(delta):
	if current:
		# Smoothly interpolate current rotation towards target rotation
		current_rotation = current_rotation.lerp(target_rotation, smoothness * delta)
		
		# Apply the smoothed rotation to the spring arm
		spring_arm.rotation = current_rotation
