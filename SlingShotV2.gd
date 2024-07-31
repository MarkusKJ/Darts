# This script is attached to a Node3D in the scene, which is a 3D object.
extends Node3D

# These variables are references to other nodes in the scene.
# They are set when the script is ready, using the @onready annotation.
@onready var dart: RigidBody3D = $dart  # The dart object that will be thrown.
@onready var aim_line: MeshInstance3D = $dart/AimLine  # A line that shows the aiming direction.
@onready var power_indicator: ProgressBar = $CanvasLayer/PowerIndicator  # A progress bar that shows the throw power.
@onready var ta_powerhorizon: Control = $CanvasLayer/TouchAreaPowerHorizontal  # An area that detects touch input.
@onready var ta_vertical: Control = $CanvasLayer/TouchAreaVertical

var max_rotation_y = deg_to_rad(90)  # 90 degrees left and right
var max_rotation_x = deg_to_rad(45)  # 45 degrees up and down

# These variables keep track of the touch input.
var initial_touch_position: Vector2  # The position where the touch started.
var is_aiming: bool = false  # Whether the player is currently aiming.
var current_touch_index: int = -1  # The index of the current touch event.

# This function is called when the script is ready.
func _ready() -> void:
	# Hide the aim line and power indicator at first.
	aim_line.visible = false
	power_indicator.visible = false
	
	# Connect the touch area's input signal to the _on_ta_powerhorizon_input function.
	ta_powerhorizon.gui_input.connect(_on_ta_powerhorizon_input)
	ta_vertical.gui_input.connect(_on_ta_vertical_input)
	

# This function is called when there is touch input in the touch area.
func _on_ta_powerhorizon_input(event: InputEvent) -> void:
	# If the event is a touch press and the player is not aiming, start aiming.
	if event is InputEventScreenTouch and event.pressed and not is_aiming:
		_start_aiming(event)
	# If the event is a touch release and the player is aiming, release the dart.
	elif event is InputEventScreenTouch and not event.pressed and is_aiming and event.index == current_touch_index:
		_release_dart()
	# If the event is a touch drag and the player is aiming, update the aim.
	elif event is InputEventScreenDrag and is_aiming and event.index == current_touch_index:
		_update_aim(event)

func _on_ta_vertical_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		var vertical_drag = event.relative.y
		var rotation_amount = deg_to_rad(vertical_drag * 0.5)  # Adjust sensitivity as needed
		#HELPER
		_rotate_dart_vertical(rotation_amount)
		
		# Rotate the dart around its local X axis
		dart.rotate_object_local(Vector3.RIGHT, rotation_amount)
		
		# Clamp the rotation to prevent over-rotation
		var current_rotation = dart.rotation.x
		current_rotation = clamp(current_rotation, -max_rotation_x, max_rotation_x)
		dart.rotation.x = current_rotation
		
		# Update the aim line to match the dart's rotation
		aim_line.global_transform = dart.global_transform
		aim_line.rotate_object_local(Vector3.RIGHT, PI/2)
		
	
# This function starts the aiming process.
func _start_aiming(event: InputEventScreenTouch) -> void:
	# Store the initial touch position and the current touch index.
	initial_touch_position = event.position
	current_touch_index = event.index
	is_aiming = true
	
	# Show the aim line and power indicator.
	aim_line.visible = true
	power_indicator.visible = true
	
	# Reset the dart's vertical rotation
	dart.rotation.x = 0

# This function updates the aim based on the touch drag event.
func _update_aim(event: InputEventScreenDrag) -> void:
	# Calculate the drag vector (the distance and direction of the drag).
	var drag_vector = event.position - initial_touch_position
	
	# Calculate the aim direction, focusing on horizontal movement (x and z axes).
	var aim_direction = Vector3(drag_vector.x, 0, drag_vector.y)
	
	# Only update the aim direction if it's significant enough.
	if aim_direction.length_squared() > 0.001:
		# Position the aim line at the dart's position
		aim_line.global_position = dart.global_position
		
		# Create a basis that combines the horizontal aim and the dart's vertical rotation
		var aim_basis = Basis(Vector3.UP, atan2(-aim_direction.x, -aim_direction.z))
		aim_basis = aim_basis.rotated(Vector3.RIGHT, dart.rotation.x)
		
		# Apply the rotation to the aim line
		aim_line.global_transform.basis = aim_basis
		
		# Rotate an additional 90 degrees around the local X axis to lay the cylinder flat
		aim_line.rotate_object_local(Vector3.RIGHT, PI/2)
		
		# Adjust the length of the aim line based on the drag distance
		var aim_length = clamp(drag_vector.length() / 100, 2, 10)  # Adjust these values as needed
		aim_line.scale = Vector3(2, aim_length, 2)  # Adjust width (X and Z) as needed
	
	# Calculate the throw power based on the drag distance.
	var power = clamp(drag_vector.length() / 500, 0, 1)
	
	# Set the dart's throw direction and power, considering vertical rotation
	var throw_direction = -aim_direction.normalized().rotated(Vector3.RIGHT, dart.rotation.x)
	dart.set_throw_vector(throw_direction, power)
	
	# Update the power indicator to show the current throw power.
	power_indicator.value = power * 100

# This function releases the dart.
func _release_dart() -> void:
	# Throw the dart.
	dart.throw_dart()
	
	# Hide the aim line and power indicator.
	aim_line.visible = false
	power_indicator.visible = false
	
	# Reset the aiming state.
	is_aiming = false
	current_touch_index = -1
	
#--------------------------------------------------------------------------------------------------#
"""HELPER FUNCTIONS FOR DEVELOPMENT PURPOSES"""
#--------------------------------------------------------------------------------------------------#
func _process(delta: float) -> void:
	if is_aiming:
		_handle_keyboard_vertical_input(delta)

func _handle_keyboard_vertical_input(delta: float) -> void:
	var rotation_amount = 0
	if Input.is_key_pressed(KEY_W):
		rotation_amount = -1  # Rotate upwards
	elif Input.is_key_pressed(KEY_S):
		rotation_amount = 1   # Rotate downwards
	
	if rotation_amount != 0:
		_rotate_dart_vertical(rotation_amount * delta * 2)  # Adjust the multiplier for speed
		
		
		
func _rotate_dart_vertical(rotation_amount: float) -> void:
	# Rotate the dart around its local X axis
	dart.rotate_object_local(Vector3.RIGHT, rotation_amount)

	# Clamp the rotation to prevent over-rotation
	var current_rotation = dart.rotation.x
	current_rotation = clamp(current_rotation, -max_rotation_x, max_rotation_x)
	dart.rotation.x = current_rotation

	# Update the aim line to match the dart's rotation
	if aim_line.visible:
		aim_line.global_transform = dart.global_transform
		aim_line.rotate_object_local(Vector3.RIGHT, PI/2)
