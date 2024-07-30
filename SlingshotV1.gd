# This script is attached to a Node3D in the scene and handles the aiming and throwing of a dart.

extends Node3D

# Get references to the dart, aim line, and power indicator nodes in the scene.
@onready var dart: RigidBody3D = $DartTest
@onready var aim_line: MeshInstance3D = $AimLine
@onready var power_indicator: ProgressBar = $PowerIndicator

# Store the position where the player starts dragging the mouse.
var drag_start_position: Vector3

# Flag to check if the player is currently aiming.
var is_aiming: bool = false

# Called when the node is initialized.
func _ready() -> void:
    # Hide the aim line and power indicator by default.
    aim_line.visible = false
    power_indicator.visible = false
    
    # Create a new material for the aim line and set its color to red.
    var material = StandardMaterial3D.new()
    material.albedo_color = Color.RED
    material.emission_enabled = true
    material.emission = Color.RED
    material.emission_energy = 2.0
    material.flags_unshaded = true
    aim_line.material_override = material
    
    # Increase the size of the aim line.
    aim_line.scale = Vector3(0.1, 0.1, 1.0)
    
    # Make the aim line render on top of everything else.
    aim_line.material_override.render_priority = 100
    
    # Print a debug message to confirm the aim line's visibility.
    print("Initial aim_line visibility: ", aim_line.visible)

# Called whenever an input event occurs.
func _input(event: InputEvent) -> void:
    # Check if the event is a mouse button press or release.
    if event is InputEventMouseButton:
        # Check if the left mouse button was pressed.
        if event.button_index == MOUSE_BUTTON_LEFT:
            # If the button was pressed, start aiming.
            if event.pressed:
                print("Left mouse button pressed. Attempting to start aiming.")  # Debug print
                start_aiming(event.position)
            # If the button was released, throw the dart.
            else:
                print("Left mouse button released. Throwing dart.")  # Debug print
                throw_dart()
        # Check if the right mouse button was pressed.
        elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
            # If the button was pressed, reset the dart.
            print("Right mouse button pressed. Resetting dart.")  # Debug print
            dart.reset_dart()

# Called every frame.
func _process(delta: float) -> void:
    # If the player is aiming, update the aim line's position and direction.
    if is_aiming:
        update_aim(get_viewport().get_mouse_position())

# Start aiming when the player presses the left mouse button.
func start_aiming(mouse_position: Vector2) -> void:
    # Print a debug message to confirm the start of aiming.
    print("start_aiming called with mouse position: ", mouse_position)  # Debug print
    
    # Get the intersection point of the mouse ray with the scene.
    var intersect = get_mouse_intersect(mouse_position)
    
    # Print a debug message to confirm the intersection result.
    print("Intersect result: ", intersect)  # Debug print
    
    # If the intersection point is valid and it's on the dart, start aiming.
    if intersect and intersect.collider == dart:
        is_aiming = true
        drag_start_position = intersect.position
        
        # Initialize the aim line's position and direction.
        aim_line.global_position = dart.global_position + dart.global_transform.basis.z * 1
        aim_line.scale = Vector3.ONE  # Reset scale
        aim_line.visible = true
        
        # Print debug messages to confirm the aim line's visibility and position.
        print("Aiming started. Aim line should be visible.")  # Debug print
        print("Aim line position: ", aim_line.global_position)  # Debug print
        print("Aim line visibility: ", aim_line.visible)  # Debug print
        
        # Show the power indicator.
        power_indicator.visible = true
    else:
        # Print a debug message if the aiming conditions are not met.
        print("start_aiming conditions not met")  # Debug print

# Update the aim line's position and direction based on the mouse position.
func update_aim(mouse_position: Vector2) -> void:
    # Get the intersection point of the mouse ray with the scene.
    var intersect = get_mouse_intersect(mouse_position)
    
    # If the intersection point is valid, update the aim line.
    if intersect:
        # Calculate the drag vector and its length.
        var drag_vector = drag_start_position - intersect.position
        var drag_length = drag_vector.length()
        
        # Print a debug message to confirm the drag length.
        print("Drag length: ", drag_length)  # Debug print
        
        # Calculate the power of the throw based on the drag length.
        var max_drag = 3.0  # Adjust based on your scene scale
        var power = clamp(drag_length / max_drag, 0.0, 1.0)
        
        # Print a debug message to confirm the power.
        print("Updating aim line. Power: ", power)  # Debug print
        
        # Update the aim line's position and direction.
        aim_line.visible = true
        aim_line.global_position = dart.global_position + dart.global_transform.basis.z * 0.1
        
        # If the drag length is greater than a certain threshold, update the aim line's direction.
        if drag_length > 1.30:
            aim_line.look_at(aim_line.global_position + drag_vector, Vector3.FORWARD)
            aim_line.scale.z = max(0.1, drag_length)  # Ensure a minimum length
        else:
            # Set a default direction and length if the drag is too small.
            aim_line.look_at(aim_line.global_position + Vector3.FORWARD, Vector3.UP)
            aim_line.scale.z = 0.1
        
        # Update the dart's throw vector and power.
        dart.set_throw_vector(drag_vector.normalized(), power)
        
        # Print debug messages to confirm the aim line's position, scale, and visibility.
        print("Aim line position: ", aim_line.global_position)  # Debug print
        print("Aim line scale: ", aim_line.scale)  # Debug print
        print("Aim line visibility: ", aim_line.visible)  # Debug print
    else:
        # Print a debug message if there is no intersection.
        print("No intersection")  # Debug print
        
        # Hide the aim line and reset the dart's throw vector and power.
        aim_line.visible = false
        dart.set_throw_vector(Vector3.ZERO, 0)

# Throw the dart when the player releases the left mouse button.
func throw_dart() -> void:
    # If the player is aiming, throw the dart.
    if is_aiming:
        is_aiming = false
        aim_line.visible = false
        power_indicator.visible = false
        
        # Print a debug message to confirm the throw.
        print("Throwing dart. Aim line visibility set to: ", aim_line.visible)  # Debug print
        
        # Throw the dart.
        dart.throw_dart()

# Get the intersection point of the mouse ray with the scene.
func get_mouse_intersect(mouse_position: Vector2) -> Dictionary:
    # Get the camera and its ray origin and normal.
    var camera = get_viewport().get_camera_3d()
    var from = camera.project_ray_origin(mouse_position)
    var to = from + camera.project_ray_normal(mouse_position) * 1000
    
    # Create a ray query and intersect it with the scene.
    var space_state = get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.create(from, to)
    return space_state.intersect_ray(query)
